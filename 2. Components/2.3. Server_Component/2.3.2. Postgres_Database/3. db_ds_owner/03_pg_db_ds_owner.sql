\echo '=== START INIT SCRIPT 03_pg_db_ds_owner.sql ==='

CREATE TABLE db_ds_owner.recommandation_engine_training_table (
    user_key BIGINT,
    job_key BIGINT,
    label INT,

    -- user base
    user_age INT,
    gender VARCHAR(10),
    native_language_name VARCHAR(100),
    is_recently_active VARCHAR(1),
    is_new_user VARCHAR(1),
    account_age_days INT,

    -- user embeddings
    user_skill_embedding DOUBLE PRECISION[],
    user_cert_embedding DOUBLE PRECISION[],
    user_spec_embedding DOUBLE PRECISION[],

    -- job base
    salary_min BIGINT,
    salary_max BIGINT,
    demand_score DOUBLE PRECISION,
    complexity_score DOUBLE PRECISION,
    job_category_score DOUBLE PRECISION,
    job_title_score DOUBLE PRECISION,
    job_level_score DOUBLE PRECISION,
    employment_type_score DOUBLE PRECISION,
    work_type_score DOUBLE PRECISION,

    -- job embeddings
    job_skill_embedding DOUBLE PRECISION[],

    -- company
    company_rating DOUBLE PRECISION,
    org_health_score DOUBLE PRECISION,
    org_stability_score DOUBLE PRECISION,
    financial_health_score DOUBLE PRECISION
);

CREATE TABLE db_ds_owner.recommandation_engine_test_table (
    user_key BIGINT,
    job_key BIGINT,
    label INT,

    -- user base
    user_age INT,
    gender VARCHAR(10),
    native_language_name VARCHAR(100),
    is_recently_active VARCHAR(1),
    is_new_user VARCHAR(1),
    account_age_days INT,

    -- user embeddings
    user_skill_embedding DOUBLE PRECISION[],
    user_cert_embedding DOUBLE PRECISION[],
    user_spec_embedding DOUBLE PRECISION[],

    -- job base
    salary_min BIGINT,
    salary_max BIGINT,
    demand_score DOUBLE PRECISION,
    complexity_score DOUBLE PRECISION,
    job_category_score DOUBLE PRECISION,
    job_title_score DOUBLE PRECISION,
    job_level_score DOUBLE PRECISION,
    employment_type_score DOUBLE PRECISION,
    work_type_score DOUBLE PRECISION,

    -- job embeddings
    job_skill_embedding DOUBLE PRECISION[],

    -- company
    company_rating DOUBLE PRECISION,
    org_health_score DOUBLE PRECISION,
    org_stability_score DOUBLE PRECISION,
    financial_health_score DOUBLE PRECISION
);

\echo '========================';
\echo ' CREATE EMAIL TABLE ';
\echo '========================';

CREATE TABLE db_ds_owner.email (
    email_code       BIGINT PRIMARY KEY,
    subject          VARCHAR(250) NOT NULL,
    content          VARCHAR(250),
    attachment       BYTEA,
    arrival_time     TIMESTAMP,
    importance       VARCHAR(50),

    reply_to_email   BIGINT ,
    receiver         BIGINT,
    sender           BIGINT,

    creation_date    TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by       VARCHAR(50) NOT NULL,
    last_update_date TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by  VARCHAR(50) NOT NULL,

    source_system    VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status      VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version     BIGINT DEFAULT 1 NOT NULL,
    last_synced_at   TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag     CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_ds_owner.email OWNER TO db_ds_owner;


\echo '==================================';
\echo ' 39. CREATE JOB_APPLICATION TABLE ';
\echo '==================================';

CREATE TABLE db_ds_owner.job_application (
    application_id      BIGINT PRIMARY KEY,
    apply_date          DATE NOT NULL,
    apply_source        VARCHAR(50) NOT NULL,
    status              VARCHAR(50) NOT NULL,
    salary              VARCHAR(50) NOT NULL,

    user_id             BIGINT NOT NULL,
    job_id              BIGINT NOT NULL,

    creation_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by          VARCHAR(50) NOT NULL,
    last_update_date    TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by     VARCHAR(50) NOT NULL,

    source_system       VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status         VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version        BIGINT DEFAULT 1 NOT NULL,
    last_synced_at      TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag        CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_ds_owner.job_application OWNER TO db_ds_owner;

\echo '=== END INIT SCRIPT 03_pg_db_ds_owner.sql ==='