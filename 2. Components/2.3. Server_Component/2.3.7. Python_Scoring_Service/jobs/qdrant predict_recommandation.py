import psycopg2
from qdrant_client import QdrantClient
import numpy as np

POSTGRES_CONN = dict(
    host="postgres",
    dbname="server_interface_postgres_db",
    user="postgres_admin_owner",
    password="postgres_admin_pass"
)

qdrant = QdrantClient(host="qdrant", port=6333)


def get_user_semantic_vector(user_id: int):
    points, _ = qdrant.scroll(
        collection_name="app_events_embeddings",
        scroll_filter={
            "must": [
                {"key": "source_identifier", "match": {"value": user_id}}
            ]
        },
        limit=200
    )

    if not points:
        return None

    vectors = [p.vector for p in points]
    return np.mean(vectors, axis=0).tolist()


def get_recommended_skills(user_vector, limit=20):
    results = qdrant.search(
        collection_name="skills_embeddings",
        query_vector=user_vector,
        limit=limit
    )

    skills = []
    for r in results:
        payload = r.payload
        skills.append({
            "skill_code": payload["skill_code"],
            "skill_name": payload["skill_name"],
            "score": r.score
        })
    return skills



def get_all_users(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT DISTINCT user_id, full_name FROM db_ds_owner.user_dim;")
        return cur.fetchall()  # [(user_id, full_name), ...]


def get_user_existing_skills(conn, user_id: int):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT s.skill_code
            FROM db_ds_owner.user_skill_bridge usb
            JOIN db_ds_owner.user_skill_dim s ON s.user_skill_key = usb.user_skill_key
            JOIN db_ds_owner.user_dim u ON u.user_key = usb.user_key
            WHERE u.user_id = %s;
        """, (user_id,))
        rows = cur.fetchall()
        return {r[0] for r in rows}  # set of skill_code


def insert_email(conn, user_id: int, subject: str, content: str):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO db_ds_owner.email
            (email_code, subject, content, attachment, arrival_time, importance,
             reply_to_email, receiver, sender,
             created_by, last_updated_by)
            VALUES (DEFAULT, %s, %s, NULL, NOW(), 'NORMAL',
                    NULL, %s, 0,
                    'AI_QDRANT', 'AI_QDRANT');
        """, (subject, content, user_id))


def build_email_content(user_name: str, recommended_skills: list):
    lines = []
    lines.append(f"Salut, {user_name},")
    lines.append("")
    lines.append("Pe baza activității tale și a profilului tău tehnic, îți recomandăm să înveți sau să aprofundezi următoarele skill-uri:")
    lines.append("")

    for s in recommended_skills:
        lines.append(f"- {s['skill_name']}")

    lines.append("")
    lines.append("Aceste recomandări sunt generate automat folosind analiza semantică a evenimentelor tale și a skill-urilor similare din platformă.")
    lines.append("")
    lines.append("Succes la învățat,")
    lines.append("AI Career Coach (Qdrant)")

    return "\n".join(lines)


def run_qdrant_learning_recommender():
    conn = psycopg2.connect(**POSTGRES_CONN)

    users = get_all_users(conn)

    for user_id, full_name in users:
        print(f"=== User {user_id} / {full_name} ===")

        # 1) vector semantic din Qdrant
        user_vec = get_user_semantic_vector(user_id)
        if user_vec is None:
            print("   -> No Qdrant events, skipping.")
            continue

        # 2) skill-uri recomandate din Qdrant
        skills_from_qdrant = get_recommended_skills(user_vec, limit=30)

        # 3) skill-uri pe care userul le are deja
        existing_skill_codes = get_user_existing_skills(conn, user_id)

        # 4) filtrăm skill-urile deja cunoscute
        filtered = [
            s for s in skills_from_qdrant
            if s["skill_code"] not in existing_skill_codes
        ]

        # 5) luăm top N (ex: 5)
        top_recommended = filtered[:5]
        if not top_recommended:
            print("   -> No new skills to recommend.")
            continue

        # 6) generăm content de email
        content = build_email_content(full_name, top_recommended)

        # 7) inserăm în tabela email
        insert_email(
            conn,
            user_id=user_id,
            subject="Recomandări de skill-uri pe care să le înveți",
            content=content
        )

        print(f"   -> Inserted email with {len(top_recommended)} skill recommendations.")

    conn.commit()
    conn.close()
    print("=== QDRANT LEARNING RECOMMENDER DONE ===")


if __name__ == "__main__":
    run_qdrant_learning_recommender()
