from pyspark.sql import SparkSession
from pyspark.sql.functions import col, udf
from pyspark.sql.types import StringType, ArrayType, DoubleType
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct, VectorParams
import json


model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

def embed_text(text):
    if text is None:
        text = ""
    vec = model.encode(text)
    return vec.tolist()

embed_udf = udf(embed_text, ArrayType(DoubleType()))


spark = SparkSession.builder \
    .appName("events_to_qdrant_job") \
    .config("spark.jars", "/opt/spark/jars/ojdbc8.jar") \
    .getOrCreate()

spark.sparkContext.setLogLevel("INFO")


oracle_url = "jdbc:oracle:thin:@techhunter_high?TNS_ADMIN=/opt/oracle_wallet"

oracle_props = {
    "user": "AUTONOMOUS_DB_OWNER",
    "password": "DbOwnerPass",
    "driver": "oracle.jdbc.driver.OracleDriver"
}

events_df = spark.read.jdbc(
    url=oracle_url,
    table="AUTONOMOUS_DB_OWNER.APP_EVENTS_STREAM",
    properties=oracle_props
)

# Convert CLOB to string
events_df = events_df.withColumn(
    "json_text",
    col("t_dl_source_msg").cast(StringType())
)

events_df = events_df.withColumn(
    "embedding",
    embed_udf(col("json_text"))
)


events = events_df.select(
    "event_id",
    "event_timestamp",
    "event_code",
    "event_subcode",
    "source_identifier",
    "json_text",
    "embedding"
).collect()


client = QdrantClient(host="qdrant", port=6333)

# Create collection if not exists
client.recreate_collection(
    collection_name="app_events_embeddings",
    vectors_config=VectorParams(size=384, distance="Cosine")
)


points = []

for row in events:
    payload = {
        "event_id": row.event_id,
        "event_timestamp": str(row.event_timestamp),
        "event_code": row.event_code,
        "event_subcode": row.event_subcode,
        "source_identifier": row.source_identifier,
        "json": row.json_text
    }

    points.append(
        PointStruct(
            id=row.event_id,
            vector=row.embedding,
            payload=payload
        )
    )

client.upsert(
    collection_name="app_events_embeddings",
    points=points
)

print("All events successfully embedded and inserted into Qdrant.")
spark.stop()
