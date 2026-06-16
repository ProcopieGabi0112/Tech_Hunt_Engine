from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, udf, collect_list, concat_ws, when
)
from pyspark.sql.types import ArrayType, DoubleType, StringType
from sentence_transformers import SentenceTransformer
import json

model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

def embed_text(text):
    if text is None:
        text = ""
    vec = model.encode(text)
    return vec.tolist()

embed_udf = udf(embed_text, ArrayType(DoubleType()))


spark = SparkSession.builder \
    .appName("recommandation_engine_training_job") \
    .config("spark.jars", "/opt/spark/jars/ojdbc8.jar,/opt/spark/jars/postgresql-42.7.3.jar") \
    .getOrCreate()

spark.sparkContext.setLogLevel("INFO")


oracle_url = "jdbc:oracle:thin:@techhunter_high?TNS_ADMIN=/opt/oracle_wallet"

oracle_props = {
    "user": "AUTONOMOUS_DW_OWNER",
    "password": "DwOwnerPass",
    "driver": "oracle.jdbc.driver.OracleDriver"
}

user_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_USER_DIM", oracle_props)
user_loc_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_USER_LOCATION_DIM", oracle_props)

user_skill_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_USER_SKILL_DIM", oracle_props)
user_skill_bridge = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_USER_SKILL_BRIDGE", oracle_props)

cert_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_CERTIFICATION_DIM", oracle_props)
user_cert_bridge = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_USER_CERTIFICATION_BRIDGE", oracle_props)

spec_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_SPECIALIZATION_DIM", oracle_props)
user_spec_bridge = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_USER_SPECIALIZATION_BRIDGE", oracle_props)

job_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_JOB_DIM", oracle_props)
job_loc_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_JOB_LOCATION_DIM", oracle_props)

job_skill_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_JOB_SKILL_DIM", oracle_props)
job_skill_bridge = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_JOB_SKILL_BRIDGE", oracle_props)

company_dim = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_COMPANY_DIM", oracle_props)

application_fact = spark.read.jdbc(oracle_url, "AUTONOMOUS_DW_OWNER.DWH_APPLICATION_FACT", oracle_props)


user_base = user_dim.select(
    col("user_key"),
    col("user_age"),
    col("gender"),
    col("native_language_name"),
    col("is_recently_active"),
    col("is_new_user"),
    col("account_age_days"),
    # presupunem că există coloana report_send_flag în DWH_USER_DIM
    col("report_send_flag")
)


user_skills = user_skill_bridge.join(
    user_skill_dim,
    on="user_skill_key",
    how="left"
).select(
    col("user_key"),
    col("skill_name")
)

user_skills_agg = user_skills.groupBy("user_key") \
    .agg(concat_ws(" ", collect_list("skill_name")).alias("user_skill_text")) \
    .withColumn("user_skill_embedding", embed_udf(col("user_skill_text")))


user_certs = user_cert_bridge.join(
    cert_dim,
    on="certification_key",
    how="left"
).select(
    col("user_key"),
    col("certification_name"),
    col("language_name")
)

user_certs_agg = user_certs.groupBy("user_key") \
    .agg(
        concat_ws(" ", collect_list("certification_name")).alias("cert_text"),
        concat_ws(" ", collect_list("language_name")).alias("lang_text")
    )

user_certs_agg = user_certs_agg.withColumn(
    "user_cert_text",
    concat_ws(" ", col("cert_text"), col("lang_text"))
).withColumn(
    "user_cert_embedding",
    embed_udf(col("user_cert_text"))
)


user_specs = user_spec_bridge.join(
    spec_dim,
    on="specialization_key",
    how="left"
).select(
    col("user_key"),
    col("specialization_name"),
    col("degree_type"),
    col("institution_name")
)

user_specs_agg = user_specs.groupBy("user_key") \
    .agg(
        concat_ws(" ", collect_list("specialization_name")).alias("spec_text"),
        concat_ws(" ", collect_list("degree_type")).alias("degree_text"),
        concat_ws(" ", collect_list("institution_name")).alias("inst_text")
    )

user_specs_agg = user_specs_agg.withColumn(
    "user_spec_text",
    concat_ws(" ", col("spec_text"), col("degree_text"), col("inst_text"))
).withColumn(
    "user_spec_embedding",
    embed_udf(col("user_spec_text"))
)


job_base = job_dim.join(
    company_dim,
    on="company_key",
    how="left"
).select(
    col("job_key"),
    col("salary_min"),
    col("salary_max"),
    col("demand_score"),
    col("complexity_score"),
    col("job_category_score"),
    col("job_title_score"),
    col("job_level_score"),
    col("employment_type_score"),
    col("work_type_score"),
    col("company_rating"),
    col("org_health_score"),
    col("org_stability_score"),
    col("financial_health_score")
)


job_skills = job_skill_bridge.join(
    job_skill_dim,
    on="job_skill_key",
    how="left"
).select(
    col("job_key"),
    col("skill_name")
)

job_skills_agg = job_skills.groupBy("job_key") \
    .agg(concat_ws(" ", collect_list("skill_name")).alias("job_skill_text")) \
    .withColumn("job_skill_embedding", embed_udf(col("job_skill_text")))


# presupunem: label = 1 dacă application_status = 'HIRED', altfel 0
labels_df = application_fact.select(
    col("user_key"),
    col("job_key"),
    when(col("application_status") == "HIRED", 1).otherwise(0).alias("label")
)


dataset = labels_df \
    .join(user_base, "user_key") \
    .join(user_skills_agg, "user_key", "left") \
    .join(user_certs_agg, "user_key", "left") \
    .join(user_specs_agg, "user_key", "left") \
    .join(job_base, "job_key") \
    .join(job_skills_agg, "job_key", "left")


training_df = dataset.filter(col("report_send_flag") == "Y")
test_df = dataset.filter(col("report_send_flag") == "N")


training_out = training_df.select(
    col("user_key"),
    col("job_key"),
    col("label"),
    col("user_age"),
    col("gender"),
    col("native_language_name"),
    col("is_recently_active"),
    col("is_new_user"),
    col("account_age_days"),
    col("user_skill_embedding"),
    col("user_cert_embedding"),
    col("user_spec_embedding"),
    col("salary_min"),
    col("salary_max"),
    col("demand_score"),
    col("complexity_score"),
    col("job_category_score"),
    col("job_title_score"),
    col("job_level_score"),
    col("employment_type_score"),
    col("work_type_score"),
    col("job_skill_embedding"),
    col("company_rating"),
    col("org_health_score"),
    col("org_stability_score"),
    col("financial_health_score")
)

test_out = test_df.select(
    col("user_key"),
    col("job_key"),
    col("label"),
    col("user_age"),
    col("gender"),
    col("native_language_name"),
    col("is_recently_active"),
    col("is_new_user"),
    col("account_age_days"),
    col("user_skill_embedding"),
    col("user_cert_embedding"),
    col("user_spec_embedding"),
    col("salary_min"),
    col("salary_max"),
    col("demand_score"),
    col("complexity_score"),
    col("job_category_score"),
    col("job_title_score"),
    col("job_level_score"),
    col("employment_type_score"),
    col("work_type_score"),
    col("job_skill_embedding"),
    col("company_rating"),
    col("org_health_score"),
    col("org_stability_score"),
    col("financial_health_score")
)


pg_url = "jdbc:postgresql://postgres_server:5432/serverdb"

pg_props = {
    "user": "admin",
    "password": "admin",
    "driver": "org.postgresql.Driver"
}

training_out.write.jdbc(
    url=pg_url,
    table="db_ds_owner.recommandation_engine_training_table",
    mode="append",
    properties=pg_props
)

test_out.write.jdbc(
    url=pg_url,
    table="db_ds_owner.recommandation_engine_test_table",
    mode="append",
    properties=pg_props
)

print("Training & Test datasets successfully written to Postgres.")
spark.stop()
