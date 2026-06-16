import schedule
import time
import psycopg2
import subprocess

POSTGRES = dict(
    host="postgres",
    dbname="server_interface_postgres_db",
    user="postgres_admin_owner",
    password="postgres_admin_pass"
)

def has_test_data():
    conn = psycopg2.connect(**POSTGRES)
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM db_ds_owner.recommandation_engine_test_table")
    count = cur.fetchone()[0]
    conn.close()
    return count > 0

def delete_test_data():
    conn = psycopg2.connect(**POSTGRES)
    cur = conn.cursor()
    cur.execute("DELETE FROM db_ds_owner.recommandation_engine_test_table")
    conn.commit()
    conn.close()
    print("=== TEST TABLE CLEARED ===")

def run_dual_tower():
    print("=== RUNNING DUAL TOWER RECOMMENDER ===")
    result = subprocess.run(
        ["python3", "/app/jobs/dual_tower_predict_job.pt"],
        capture_output=True,
        text=True
    )
    print(result.stdout)
    print(result.stderr)
    return result.returncode == 0

def run_qdrant():
    print("=== RUNNING QDRANT LEARNING RECOMMENDER ===")
    result = subprocess.run(
        ["python3", "/app/jobs/job_qdrant_learning.py"],
        capture_output=True,
        text=True
    )
    print(result.stdout)
    print(result.stderr)
    return result.returncode == 0

def run_recommenders():
    print("=== CHECKING TEST TABLE ===")
    if not has_test_data():
        print("=== NO DATA → SKIP ===")
        return

    print("=== DATA FOUND → RUNNING BOTH JOBS ===")

    ok1 = run_dual_tower()
    ok2 = run_qdrant()

    if ok1 and ok2:
        print("=== BOTH JOBS SUCCESSFUL → DELETING TEST DATA ===")
        delete_test_data()
    else:
        print("=== ONE OR BOTH JOBS FAILED → TEST DATA KEPT ===")

def main():
    print("=== RECOMMENDATION SCHEDULER STARTED ===")

    # rulează la fiecare 30 secunde
    schedule.every(30).seconds.do(run_recommenders)

    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    main()
