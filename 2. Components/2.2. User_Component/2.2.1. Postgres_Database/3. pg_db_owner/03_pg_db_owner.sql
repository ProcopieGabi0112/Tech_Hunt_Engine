\echo '=== START INIT SCRIPT 03_pg_db_owner.sql ==='

\echo '==============================';
\echo ' X1. CREATE SKILL AREA TABLES ';
\echo '==============================';

\echo '=================================';
\echo ' 1. CREATE TECHNOLOGY_TYPE TABLE ';
\echo '=================================';

CREATE TABLE db_owner.technology_type (
    technology_type_code BIGINT PRIMARY KEY,
    name                 VARCHAR(50) NOT NULL,
    rating               NUMERIC(5,2) DEFAULT 0 NOT NULL,
    description          VARCHAR(300),

    creation_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by           VARCHAR(50) NOT NULL,
    last_update_date     TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by      VARCHAR(50) NOT NULL,
    source_system        VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status          VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version         BIGINT DEFAULT 1 NOT NULL,
    last_synced_at       TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag         CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.technology_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.technology_type IS 'The table contains the types of technologies';

COMMENT ON COLUMN db_owner.technology_type.technology_type_code IS 'The code of the technology type';
COMMENT ON COLUMN db_owner.technology_type.name IS 'The name of the technology type';
COMMENT ON COLUMN db_owner.technology_type.rating IS 'The rating of the technology type';
COMMENT ON COLUMN db_owner.technology_type.description IS 'The description of the technology type';

COMMENT ON COLUMN db_owner.technology_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.technology_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.technology_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.technology_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.technology_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.technology_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.technology_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.technology_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.technology_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_technology_type_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_technology_type_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.technology_type_code IS NULL THEN
        NEW.technology_type_code := nextval('db_tech_owner.seq_technology_type_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_type_code_pk
BEFORE INSERT ON db_owner.technology_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_technology_type_code_pk();    

CREATE OR REPLACE FUNCTION db_owner.fn_technology_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER db_ownertrg_technology_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.technology_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_technology_type_tech_col();

ALTER SEQUENCE db_owner.seq_technology_type_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_technology_type_code
TO db_owner;


\echo '============================';
\echo ' 2. CREATE TECHNOLOGY TABLE ';
\echo '============================';    

CREATE TABLE db_owner.technology (
    technology_code        BIGINT PRIMARY KEY,
    name                   VARCHAR(100),
    release_date           DATE,
    creator                VARCHAR(100),
    official_site          VARCHAR(255),
    rating                 NUMERIC(5,2) DEFAULT 0 NOT NULL,
    description            VARCHAR(300),
    sign_photo             BYTEA,
    technology_type_code   BIGINT NOT NULL REFERENCES db_owner.technology_type(technology_type_code),

    creation_date          TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by             VARCHAR(50) NOT NULL,
    last_update_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by        VARCHAR(50) NOT NULL,
    source_system          VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status            VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version           BIGINT DEFAULT 1 NOT NULL,
    last_synced_at         TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag           CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.technology OWNER TO db_owner;

COMMENT ON TABLE db_owner.technology IS
'This table contains technologies like PostgreSQL, Spring Boot, React Native, etc';

COMMENT ON COLUMN db_owner.technology.technology_code IS 'The code of the technology';
COMMENT ON COLUMN db_owner.technology.name IS 'The name of the technology';
COMMENT ON COLUMN db_owner.technology.release_date IS 'The release date of the technology';
COMMENT ON COLUMN db_owner.technology.creator IS 'The creator of the technology';
COMMENT ON COLUMN db_owner.technology.official_site IS 'The official site of the technology';
COMMENT ON COLUMN db_owner.technology.rating IS 'The rating of the technology';
COMMENT ON COLUMN db_owner.technology.description IS 'The description of the technology';
COMMENT ON COLUMN db_owner.technology.sign_photo IS 'The sign photo of the technology';
COMMENT ON COLUMN db_owner.technology.technology_type_code IS 'The code of the technology type';

COMMENT ON COLUMN db_owner.technology.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.technology.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.technology.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.technology.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.technology.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.technology.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.technology.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.technology.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.technology.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_technology_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_technology_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.technology_code IS NULL THEN
        NEW.technology_code := nextval('db_owner.seq_technology_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_code_pk
BEFORE INSERT ON db_owner.technology
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_technology_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_technology_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_tech_col
BEFORE INSERT OR UPDATE ON db_owner.technology
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_technology_tech_col();

CREATE OR REPLACE FUNCTION db_owner.fn_sync_technology_type_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE db_owner.technology_type tt
    SET rating = (
        SELECT COALESCE(AVG(t.rating), 0)
        FROM db_owner.technology t
        WHERE t.technology_type_code = tt.technology_type_code
    )
    WHERE tt.technology_type_code IN (
        OLD.technology_type_code,
        NEW.technology_type_code
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_type_rating_sync
AFTER INSERT OR UPDATE OR DELETE ON db_owner.technology
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_sync_technology_type_rating();

ALTER SEQUENCE db_owner.seq_technology_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_technology_code
TO db_owner;


\echo '=========================';
\echo ' 3. CREATE VERSION TABLE ';
\echo '=========================';    

CREATE TABLE db_owner.version (
    version_code            BIGINT PRIMARY KEY,
    name                    VARCHAR(100) NOT NULL,
    release_date            DATE NOT NULL,
    end_of_life             DATE,
    new_features            VARCHAR(200) NOT NULL,
    unsolved_problems       VARCHAR(200),
    creator                 VARCHAR(100) NOT NULL,
    developer_popularity    NUMERIC(5,2) NOT NULL,
    community_support       NUMERIC(5,2) NOT NULL,
    industry_usage_score    NUMERIC(5,2) NOT NULL,
    knowledge_score         NUMERIC(5,2) NOT NULL,
    skills_rating           NUMERIC(5,2) NOT NULL,

    -- rating calculat automat
    rating NUMERIC(5,2) GENERATED ALWAYS AS (
        ROUND(
            0.30 * industry_usage_score +
            0.20 * community_support +
            0.20 * developer_popularity +
            0.15 * skills_rating +
            0.15 * knowledge_score
        , 2)
    ) STORED,

    description             VARCHAR(200),
    technology_code         BIGINT REFERENCES db_owner.technology(technology_code),

    creation_date           TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by              VARCHAR(50) NOT NULL,
    last_update_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by         VARCHAR(50) NOT NULL,
    source_system           VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status             VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version            BIGINT DEFAULT 1 NOT NULL,
    last_synced_at          TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag            CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.version OWNER TO db_owner;

COMMENT ON TABLE db_owner.version IS
'The table contains the information about versions of each technology.';

COMMENT ON COLUMN db_owner.version.version_code IS 'The code of the technology version';
COMMENT ON COLUMN db_owner.version.name IS 'The name of the technology version';
COMMENT ON COLUMN db_owner.version.description IS 'The description of the technology version';
COMMENT ON COLUMN db_owner.version.release_date IS 'The release date of the technology version';
COMMENT ON COLUMN db_owner.version.end_of_life IS 'The end of life of the technology version';
COMMENT ON COLUMN db_owner.version.new_features IS 'The new features of the technology version';
COMMENT ON COLUMN db_owner.version.unsolved_problems IS 'The unsolved problems of the technology version';
COMMENT ON COLUMN db_owner.version.creator IS 'The creator of the technology version';
COMMENT ON COLUMN db_owner.version.developer_popularity IS 'Developer popularity score';
COMMENT ON COLUMN db_owner.version.community_support IS 'Community support score';
COMMENT ON COLUMN db_owner.version.industry_usage_score IS 'Industry usage score';
COMMENT ON COLUMN db_owner.version.knowledge_score IS 'Knowledge score';
COMMENT ON COLUMN db_owner.version.skills_rating IS 'Skills rating';
COMMENT ON COLUMN db_owner.version.rating IS 'Overall calculated rating';
COMMENT ON COLUMN db_owner.version.technology_code IS 'The code of the technology';

COMMENT ON COLUMN db_owner.version.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.version.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.version.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.version.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.version.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.version.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.version.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.version.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.version.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_version_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_version_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.version_code IS NULL THEN
        NEW.version_code := nextval('db_owner.seq_version_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_version_code_pk
BEFORE INSERT ON db_owner.version
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_version_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_version_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_version_tech_col
BEFORE INSERT OR UPDATE ON db_owner.version
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_version_tech_col();

CREATE OR REPLACE FUNCTION db_owner.fn_sync_technology_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE db_owner.technology t
    SET rating = (
        SELECT COALESCE(AVG(v.rating), 0)
        FROM db_owner.version v
        WHERE v.technology_code = t.technology_code
    )
    WHERE t.technology_code IN (OLD.technology_code, NEW.technology_code);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_rating_sync
AFTER INSERT OR UPDATE OR DELETE ON db_owner.version
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_sync_technology_rating();

ALTER SEQUENCE db_owner.seq_version_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_version_code
TO db_owner;


\echo '=======================';
\echo ' 4. CREATE SKILL TABLE ';
\echo '=======================';   

CREATE TABLE db_owner.skill (
    skill_code                   BIGINT PRIMARY KEY,
    name                         VARCHAR(200) NOT NULL,
    prerequisite_knowledge       NUMERIC(5,2) NOT NULL,
    learning_difficulty          NUMERIC(5,2) NOT NULL,
    implementation_difficulty    NUMERIC(5,2) NOT NULL,
    cross_platform_applicability NUMERIC(5,2) NOT NULL,
    rating NUMERIC(5,2) GENERATED ALWAYS AS (
        ROUND(
            0.35 * prerequisite_knowledge +
            0.30 * learning_difficulty +
            0.20 * cross_platform_applicability +
            0.15 * implementation_difficulty
        , 2)
    ) STORED,

    description                 VARCHAR(200),
    last_version_code           BIGINT NOT NULL REFERENCES db_owner.version(version_code),
    first_version_code          BIGINT REFERENCES db_owner.version(version_code),

    creation_date               TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by                  VARCHAR(50) NOT NULL,
    last_update_date            TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by             VARCHAR(50) NOT NULL,
    source_system               VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status                 VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version                BIGINT DEFAULT 1 NOT NULL,
    last_synced_at              TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag                CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.skill OWNER TO db_owner;

COMMENT ON TABLE db_owner.skill IS
'The table contains the skills of each technology version.';

COMMENT ON COLUMN db_owner.skill.skill_code IS 'The code of the technology skill';
COMMENT ON COLUMN db_owner.skill.name IS 'The name of the technology skill';
COMMENT ON COLUMN db_owner.skill.prerequisite_knowledge IS 'Prerequisite knowledge score';
COMMENT ON COLUMN db_owner.skill.learning_difficulty IS 'Learning difficulty score';
COMMENT ON COLUMN db_owner.skill.implementation_difficulty IS 'Implementation difficulty score';
COMMENT ON COLUMN db_owner.skill.cross_platform_applicability IS 'Cross-platform applicability score';
COMMENT ON COLUMN db_owner.skill.rating IS 'Calculated rating of the skill';
COMMENT ON COLUMN db_owner.skill.description IS 'Description of the skill';
COMMENT ON COLUMN db_owner.skill.last_version_code IS 'The last version where this skill applies';
COMMENT ON COLUMN db_owner.skill.first_version_code IS 'The first version where this skill appears';

COMMENT ON COLUMN db_owner.skill.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.skill.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.skill.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.skill.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.skill.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.skill.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.skill.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.skill.last_synced_at IS 'Technical Column - The date when the record was last synced';
COMMENT ON COLUMN db_owner.skill.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_skill_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_skill_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.skill_code IS NULL THEN
        NEW.skill_code := nextval('db_owner.seq_skill_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_skill_code_pk
BEFORE INSERT ON db_owner.skill
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_skill_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_skill_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_skill_tech_col
BEFORE INSERT OR UPDATE ON db_owner.skill
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_skill_tech_col();

CREATE OR REPLACE FUNCTION db_owner.fn_sync_version_skill_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE db_owner.version v
    SET skills_rating = (
        SELECT COALESCE(AVG(s.rating), 0)
        FROM db_owner.skill s
        WHERE s.last_version_code = v.version_code
    )
    WHERE v.version_code IN (OLD.last_version_code, NEW.last_version_code);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_version_rating_sync
AFTER INSERT OR UPDATE OR DELETE ON db_owner.skill
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_sync_version_skill_rating();

ALTER SEQUENCE db_owner.seq_skill_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_skill_code
TO db_owner;

\echo '=======================================';
\echo ' 5. CREATE TECHNOLOGY_DEPENDENCY TABLE ';
\echo '=======================================';   

CREATE TABLE db_owner.technology_dependency (
    technology_dependency_code BIGINT PRIMARY KEY,

    source_type VARCHAR(50) NOT NULL,
    source_id   BIGINT NOT NULL,

    target_type VARCHAR(50) NOT NULL,
    target_id   BIGINT NOT NULL,

    relation VARCHAR(50) NOT NULL CHECK (relation IN (
        'requires',
        'extends',
        'implements',
        'compatible_with',
        'incompatible_with',
        'replaces',
        'deprecated_by',
        'patch_of',
        'belongs_to',
        'builds_on',
        'related_to'
    )),

    creation_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by      VARCHAR(50) NOT NULL,
    last_update_date TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by VARCHAR(50) NOT NULL,
    source_system   VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status     VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version    BIGINT DEFAULT 1 NOT NULL,
    last_synced_at  TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag    CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.technology_dependency OWNER TO db_owner;

COMMENT ON TABLE db_owner.technology_dependency IS
'Links between technologies, versions and skills. Validated via trigger because FK cannot be used dynamically.';

COMMENT ON COLUMN db_owner.technology_dependency.technology_dependency_code IS 'The dependency record ID';
COMMENT ON COLUMN db_owner.technology_dependency.source_type IS 'The source entity type (technology/version/skill)';
COMMENT ON COLUMN db_owner.technology_dependency.source_id IS 'The source entity ID';
COMMENT ON COLUMN db_owner.technology_dependency.target_type IS 'The target entity type (technology/version/skill)';
COMMENT ON COLUMN db_owner.technology_dependency.target_id IS 'The target entity ID';
COMMENT ON COLUMN db_owner.technology_dependency.relation IS 'The relation type between source and target';

COMMENT ON COLUMN db_owner.technology_dependency.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.technology_dependency.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.technology_dependency.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.technology_dependency.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.technology_dependency.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.technology_dependency.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.technology_dependency.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.technology_dependency.last_synced_at IS 'Technical Column - The date when the record was last synced';
COMMENT ON COLUMN db_owner.technology_dependency.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_technology_dependency_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

 CREATE OR REPLACE FUNCTION db_owner.fn_technology_dependency_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.technology_dependency_code IS NULL THEN
        NEW.technology_dependency_code := nextval('db_owner.seq_technology_dependency_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER trg_technology_dependency_code_pk
BEFORE INSERT ON db_owner.technology_dependency
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_technology_dependency_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_technology_dependency_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_dependency_tech_col
BEFORE INSERT OR UPDATE ON db_owner.technology_dependency
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_technology_dependency_tech_col();

CREATE OR REPLACE FUNCTION db_owner.fn_validate_technology_dependency()
RETURNS TRIGGER AS $$
DECLARE
    v_exists INT;
BEGIN
    --------------------------------------------------------------------
    -- VALIDARE SOURCE
    --------------------------------------------------------------------
    IF NEW.source_type = 'technology' THEN
        SELECT COUNT(*) INTO v_exists
        FROM db_owner.technology
        WHERE technology_code = NEW.source_id;

        IF v_exists = 0 THEN
            RAISE EXCEPTION 'Invalid source_id: technology does not exist';
        END IF;

    ELSIF NEW.source_type = 'version' THEN
        SELECT COUNT(*) INTO v_exists
        FROM db_owner.version
        WHERE version_code = NEW.source_id;

        IF v_exists = 0 THEN
            RAISE EXCEPTION 'Invalid source_id: version does not exist';
        END IF;

    ELSIF NEW.source_type = 'skill' THEN
        SELECT COUNT(*) INTO v_exists
        FROM db_owner.skill
        WHERE skill_code = NEW.source_id;

        IF v_exists = 0 THEN
            RAISE EXCEPTION 'Invalid source_id: skill does not exist';
        END IF;
    END IF;

    --------------------------------------------------------------------
    -- VALIDARE TARGET
    --------------------------------------------------------------------
    IF NEW.target_type = 'technology' THEN
        SELECT COUNT(*) INTO v_exists
        FROM db_owner.technology
        WHERE technology_code = NEW.target_id;

        IF v_exists = 0 THEN
            RAISE EXCEPTION 'Invalid target_id: technology does not exist';
        END IF;

    ELSIF NEW.target_type = 'version' THEN
        SELECT COUNT(*) INTO v_exists
        FROM db_owner.version
        WHERE version_code = NEW.target_id;

        IF v_exists = 0 THEN
            RAISE EXCEPTION 'Invalid target_id: version does not exist';
        END IF;

    ELSIF NEW.target_type = 'skill' THEN
        SELECT COUNT(*) INTO v_exists
        FROM db_owner.skill
        WHERE skill_code = NEW.target_id;

        IF v_exists = 0 THEN
            RAISE EXCEPTION 'Invalid target_id: skill does not exist';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_technology_dependency_validate
BEFORE INSERT OR UPDATE ON db_owner.technology_dependency
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_validate_technology_dependency();

ALTER SEQUENCE db_owner.seq_technology_dependency_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_technology_dependency_code
TO db_owner;

\echo '==============================';
\echo ' X2. CREATE USERS AREA TABLES ';
\echo '==============================';

\echo '======================';
\echo ' 6. CREATE ROLE TABLE ';
\echo '======================';

CREATE TABLE db_owner.role (
    role_id         BIGINT PRIMARY KEY,
    name            VARCHAR(50) NOT NULL,

    creation_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by      VARCHAR(50) NOT NULL,
    last_update_date TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by VARCHAR(50) NOT NULL,
    source_system   VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status     VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version    BIGINT DEFAULT 1 NOT NULL,
    last_synced_at  TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag    CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.role OWNER TO db_owner;

COMMENT ON TABLE db_owner.role IS
'The table contains the roles that a user can have';

COMMENT ON COLUMN db_owner.role.role_id IS 'The primary key of the role table';
COMMENT ON COLUMN db_owner.role.name IS 'The name of the role';

COMMENT ON COLUMN db_owner.role.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.role.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.role.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.role.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.role.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.role.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.role.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.role.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.role.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_role_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_role_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role_id IS NULL THEN
        NEW.role_id := nextval('db_owner.seq_role_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_role_id_pk
BEFORE INSERT ON db_owner.role
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_role_id_pk();    

CREATE OR REPLACE FUNCTION db_owner.fn_role_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_role_tech_col
BEFORE INSERT OR UPDATE ON db_owner.role
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_role_tech_col();

ALTER SEQUENCE db_owner.seq_role_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_role_id
TO db_owner;

INSERT INTO db_owner.role (name) VALUES ('STUDENT');

INSERT INTO db_owner.role (name) VALUES ('SPECIALIST_HR');

INSERT INTO db_owner.role (name) VALUES ('MANAGER');

INSERT INTO db_owner.role (name) VALUES ('ADMIN');

\echo '==========================';
\echo ' 7. CREATE LANGUAGE TABLE ';
\echo '==========================';

CREATE TABLE db_owner.language (
    lang_code              BIGINT PRIMARY KEY,
    name                   VARCHAR(60) NOT NULL,
    iso_code               VARCHAR(5) NOT NULL,
    no_native_speakers     BIGINT NOT NULL,
    no_speakers            BIGINT NOT NULL,
    no_countries           INTEGER NOT NULL,
    no_companies           BIGINT NOT NULL,

    rating NUMERIC(5,2) GENERATED ALWAYS AS (
    ROUND(
        (
            0.3 * sqrt(no_countries) +
            0.4 * log(10, no_companies + 1) +
            0.2 * log(10, no_native_speakers + 1) +
            0.1 * log(10, (no_speakers - no_native_speakers) + 1)
        )::numeric * 100 / 9.4
      , 2)
      ) STORED,

    creation_date          TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by             VARCHAR(50) NOT NULL,
    last_update_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by        VARCHAR(50) NOT NULL,
    source_system          VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status            VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version           BIGINT DEFAULT 1 NOT NULL,
    last_synced_at         TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag           CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.language OWNER TO db_owner;

COMMENT ON TABLE db_owner.language IS
'The table contains the spoken languages of students';

COMMENT ON COLUMN db_owner.language.lang_code IS 'The primary key of the language table';
COMMENT ON COLUMN db_owner.language.name IS 'The name of the language';
COMMENT ON COLUMN db_owner.language.iso_code IS 'The ISO code of the language';
COMMENT ON COLUMN db_owner.language.no_native_speakers IS 'The number of native speakers';
COMMENT ON COLUMN db_owner.language.no_speakers IS 'The total number of speakers';
COMMENT ON COLUMN db_owner.language.no_countries IS 'The number of countries where the language is spoken';
COMMENT ON COLUMN db_owner.language.no_companies IS 'The number of companies using this language';
COMMENT ON COLUMN db_owner.language.rating IS 'Calculated rating based on speakers and country spread';

COMMENT ON COLUMN db_owner.language.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.language.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.language.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.language.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.language.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.language.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.language.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.language.last_synced_at IS 'Technical Column - The date when the record was last synced';
COMMENT ON COLUMN db_owner.language.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_lang_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_lang_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.lang_code IS NULL THEN
        NEW.lang_code := nextval('db_owner.seq_lang_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lang_code_pk
BEFORE INSERT ON db_owner.language
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_lang_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_language_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_language_tech_col
BEFORE INSERT OR UPDATE ON db_owner.language
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_language_tech_col();

ALTER SEQUENCE db_owner.seq_lang_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_lang_code
TO db_owner;

\echo '============================';
\echo ' 8. CREATE LANG_LEVEL TABLE ';
\echo '============================';

CREATE TABLE db_owner.lang_level (
    lang_level_id      BIGINT PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    nivel              VARCHAR(30) NOT NULL,
    lang_code          BIGINT NOT NULL REFERENCES db_owner.language(lang_code),
    validity_period    INTEGER DEFAULT 0,
    rating             NUMERIC(5,2) DEFAULT 0 NOT NULL,
    description        VARCHAR(250),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,
    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.lang_level OWNER TO db_owner;

COMMENT ON TABLE db_owner.lang_level IS
'The table contains the certifications of every language that the students can have';

COMMENT ON COLUMN db_owner.lang_level.lang_level_id IS 'The primary key of the lang level table';
COMMENT ON COLUMN db_owner.lang_level.name IS 'The name of the certification';
COMMENT ON COLUMN db_owner.lang_level.nivel IS 'The level of the certification';
COMMENT ON COLUMN db_owner.lang_level.lang_code IS 'The language of the certification';
COMMENT ON COLUMN db_owner.lang_level.validity_period IS 'The validity period of the certification (in months)';
COMMENT ON COLUMN db_owner.lang_level.rating IS 'The rating of this certification';
COMMENT ON COLUMN db_owner.lang_level.description IS 'The description of the certification';

COMMENT ON COLUMN db_owner.lang_level.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.lang_level.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.lang_level.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.lang_level.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.lang_level.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.lang_level.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.lang_level.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.lang_level.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.lang_level.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_lang_level_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_lang_level_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.lang_level_id IS NULL THEN
        NEW.lang_level_id := nextval('db_owner.seq_lang_level_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lang_level_id_pk
BEFORE INSERT ON db_owner.lang_level
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_lang_level_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_lang_level_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lang_level_tech_col
BEFORE INSERT OR UPDATE ON db_owner.lang_level
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_lang_level_tech_col();

ALTER SEQUENCE db_owner.seq_lang_level_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_lang_level_id
TO db_owner;

\echo '=================================';
\echo ' X3. CREATE LOCATION AREA TABLES ';
\echo '=================================';

\echo '========================';
\echo ' 9. CREATE REGION TABLE ';
\echo '========================';

CREATE TABLE db_owner.region (
    region_id        BIGINT PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    code             VARCHAR(50) NOT NULL,
    description      VARCHAR(200),

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

ALTER TABLE db_owner.region OWNER TO db_owner;

COMMENT ON TABLE db_owner.region IS
'The table contains information about all distinct major geographical regions or areas of the world.';

COMMENT ON COLUMN db_owner.region.region_id IS 'The id of the region';
COMMENT ON COLUMN db_owner.region.name IS 'The name of the region';
COMMENT ON COLUMN db_owner.region.code IS 'The code of the region';
COMMENT ON COLUMN db_owner.region.description IS 'The description of the region';

COMMENT ON COLUMN db_owner.region.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.region.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.region.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.region.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.region.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.region.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.region.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.region.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.region.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_region_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_region_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.region_id IS NULL THEN
        NEW.region_id := nextval('db_owner.seq_region_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_region_id_pk
BEFORE INSERT ON db_owner.region
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_region_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_region_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_region_tech_col
BEFORE INSERT OR UPDATE ON db_owner.region
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_region_tech_col();

ALTER SEQUENCE db_owner.seq_region_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_region_id
TO db_owner;

\echo '================================';
\echo ' X4. CREATE COMPANY AREA TABLES ';
\echo '================================';

\echo '===========================';
\echo ' 10. CREATE CURRENCY TABLE ';
\echo '===========================';

CREATE TABLE db_owner.currency (
    currency_code      BIGINT PRIMARY KEY,
    name               VARCHAR(200) NOT NULL,
    code               VARCHAR(50) NOT NULL,
    description        VARCHAR(300),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,
    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.currency OWNER TO db_owner;

COMMENT ON TABLE db_owner.currency IS
'The table contains information about currencies used in major regions of the world.';

COMMENT ON COLUMN db_owner.currency.currency_code IS 'The id of the currency';
COMMENT ON COLUMN db_owner.currency.name IS 'The name of the currency';
COMMENT ON COLUMN db_owner.currency.code IS 'The code of the currency';
COMMENT ON COLUMN db_owner.currency.description IS 'The description of the currency';

COMMENT ON COLUMN db_owner.currency.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.currency.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.currency.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.currency.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.currency.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.currency.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.currency.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.currency.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.currency.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_currency_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_currency_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.currency_code IS NULL THEN
        NEW.currency_code := nextval('db_owner.seq_currency_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_currency_code_pk
BEFORE INSERT ON db_owner.currency
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_currency_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_currency_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_currency_tech_col
BEFORE INSERT OR UPDATE ON db_owner.currency
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_currency_tech_col();

ALTER SEQUENCE db_owner.seq_currency_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_currency_code
TO db_owner;


\echo '================================';
\echo ' 11. CREATE CURRENCY_RATE TABLE ';
\echo '================================';

CREATE TABLE db_owner.currency_rate (
    currency_rate_id     BIGINT PRIMARY KEY,
    rate_value           NUMERIC(18,6) NOT NULL,
    rate_type            VARCHAR(50) NOT NULL,

    from_currency_code   BIGINT REFERENCES db_owner.currency(currency_code),
    to_currency_code     BIGINT REFERENCES db_owner.currency(currency_code),

    creation_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by           VARCHAR(50) NOT NULL,
    last_update_date     TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by      VARCHAR(50) NOT NULL,
    source_system        VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status          VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version         BIGINT DEFAULT 1 NOT NULL,
    last_synced_at       TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag         CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.currency_rate OWNER TO db_owner;

COMMENT ON TABLE db_owner.currency_rate IS
'This table contains information about currency exchange rates.';

COMMENT ON COLUMN db_owner.currency_rate.currency_rate_id IS 'The id of the currency rate';
COMMENT ON COLUMN db_owner.currency_rate.rate_value IS 'The value of the currency rate';
COMMENT ON COLUMN db_owner.currency_rate.rate_type IS 'The type of the currency rate';
COMMENT ON COLUMN db_owner.currency_rate.from_currency_code IS 'The source currency of the conversion';
COMMENT ON COLUMN db_owner.currency_rate.to_currency_code IS 'The target currency of the conversion';

COMMENT ON COLUMN db_owner.currency_rate.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.currency_rate.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.currency_rate.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.currency_rate.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.currency_rate.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.currency_rate.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.currency_rate.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.currency_rate.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.currency_rate.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_currency_rate_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_currency_rate_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.currency_rate_id IS NULL THEN
        NEW.currency_rate_id := nextval('db_owner.seq_currency_rate_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_currency_rate_id_pk
BEFORE INSERT ON db_owner.currency_rate
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_currency_rate_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_currency_rate_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_currency_rate_tech_col
BEFORE INSERT OR UPDATE ON db_owner.currency_rate
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_currency_rate_tech_col();

ALTER SEQUENCE db_owner.seq_currency_rate_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_currency_rate_id
TO db_owner;


\echo '===========================';
\echo ' 12. CREATE COUNTRY TABLE  ';
\echo '===========================';

CREATE TABLE db_owner.country (
    country_id              BIGINT PRIMARY KEY,
    name                    VARCHAR(100) NOT NULL,
    code                    VARCHAR(30) NOT NULL,
    population              BIGINT NOT NULL,
    area                    BIGINT NOT NULL,
    time_zone               VARCHAR(50) NOT NULL,
    unemployment_rate       NUMERIC(5,2) NOT NULL,
    inflation_rate          NUMERIC(6,2) NOT NULL,
    average_monthly_salary  NUMERIC(10,2) NOT NULL,
    corporate_tax_rate      NUMERIC(5,2) NOT NULL,

    rating NUMERIC(5,2) GENERATED ALWAYS AS (
        ROUND(
            (
                0.30 * GREATEST(1 - (unemployment_rate / 25), 0) +
                0.25 * GREATEST(1 - (inflation_rate / 30), 0) +
                0.30 * LEAST(average_monthly_salary / 10000, 1) +
                0.15 * GREATEST(1 - (corporate_tax_rate / 35), 0)
            ) * 100
        , 2)
    ) STORED,

    region_id               BIGINT REFERENCES db_owner.region(region_id),
    official_lang_code      BIGINT REFERENCES db_owner.language(lang_code),
    currency_code           BIGINT REFERENCES db_owner.currency(currency_code),

    creation_date           TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by              VARCHAR(50) NOT NULL,
    last_update_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by         VARCHAR(50) NOT NULL,
    source_system           VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status             VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version            BIGINT DEFAULT 1 NOT NULL,
    last_synced_at          TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag            CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.country OWNER TO db_owner;

COMMENT ON TABLE db_owner.country IS
'This table contains information about countries like Romania, Bulgaria, Italy, etc.';

COMMENT ON COLUMN db_owner.country.country_id IS 'The id of the country';
COMMENT ON COLUMN db_owner.country.name IS 'The name of the country';
COMMENT ON COLUMN db_owner.country.code IS 'The code of the country';
COMMENT ON COLUMN db_owner.country.population IS 'The population of the country';
COMMENT ON COLUMN db_owner.country.area IS 'The area of the country';
COMMENT ON COLUMN db_owner.country.time_zone IS 'The time zone of the country';
COMMENT ON COLUMN db_owner.country.unemployment_rate IS 'The unemployment rate of the country';
COMMENT ON COLUMN db_owner.country.inflation_rate IS 'The inflation rate of the country';
COMMENT ON COLUMN db_owner.country.average_monthly_salary IS 'The average monthly salary of the country';
COMMENT ON COLUMN db_owner.country.corporate_tax_rate IS 'The corporate tax rate of the country';
COMMENT ON COLUMN db_owner.country.rating IS 'The calculated rating of the country';
COMMENT ON COLUMN db_owner.country.region_id IS 'The region id of the country';
COMMENT ON COLUMN db_owner.country.official_lang_code IS 'The official language code of the country';
COMMENT ON COLUMN db_owner.country.currency_code IS 'The currency code of the country';

COMMENT ON COLUMN db_owner.country.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.country.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.country.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.country.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.country.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.country.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.country.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.country.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.country.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_country_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_country_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.country_id IS NULL THEN
        NEW.country_id := nextval('db_owner.seq_country_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_country_id_pk
BEFORE INSERT ON db_owner.country
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_country_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_country_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_country_tech_col
BEFORE INSERT OR UPDATE ON db_owner.country
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_country_tech_col();

ALTER SEQUENCE db_owner.seq_country_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_country_id
TO db_owner;


\echo '============================================';
\echo ' 13. CREATE ADMINISTRATIVE_UNIT_TYPE TABLE  ';
\echo '============================================';

CREATE TABLE db_owner.administrative_unit_type (
    administrative_unit_type_id BIGINT PRIMARY KEY,
    name                        VARCHAR(50) NOT NULL,
    description                 VARCHAR(100),

    creation_date               TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by                  VARCHAR(50) NOT NULL,
    last_update_date            TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by             VARCHAR(50) NOT NULL,
    source_system               VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status                 VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version                BIGINT DEFAULT 1 NOT NULL,
    last_synced_at              TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag                CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.administrative_unit_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.administrative_unit_type IS
'This table contains information about administrative unit types like county, land, province, etc.';

COMMENT ON COLUMN db_owner.administrative_unit_type.administrative_unit_type_id IS 'The id of the administrative unit type';
COMMENT ON COLUMN db_owner.administrative_unit_type.name IS 'The name of the administrative unit type';
COMMENT ON COLUMN db_owner.administrative_unit_type.description IS 'The description of the administrative unit type';

COMMENT ON COLUMN db_owner.administrative_unit_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.administrative_unit_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.administrative_unit_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_administrative_unit_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_administrative_unit_type_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.administrative_unit_type_id IS NULL THEN
        NEW.administrative_unit_type_id := nextval('db_owner.seq_administrative_unit_type_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_administrative_unit_type_id_pk
BEFORE INSERT ON db_owner.administrative_unit_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_administrative_unit_type_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_administrative_unit_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_administrative_unit_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.administrative_unit_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_administrative_unit_type_tech_col();

ALTER SEQUENCE db_owner.seq_administrative_unit_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_administrative_unit_type_id
TO db_owner;

\echo '=======================================';
\echo ' 14. CREATE ADMINISTRATIVE_UNIT TABLE  ';
\echo '=======================================';

CREATE TABLE db_owner.administrative_unit (
    administrative_unit_id      BIGINT PRIMARY KEY,
    name                        VARCHAR(100) NOT NULL,
    code                        VARCHAR(50) NOT NULL,
    population                  BIGINT NOT NULL,
    area                        BIGINT NOT NULL,
    no_cities                   BIGINT,
    description                 VARCHAR(200),

    administrative_unit_type_id BIGINT NOT NULL REFERENCES db_owner.administrative_unit_type(administrative_unit_type_id),
    country_id                  BIGINT NOT NULL REFERENCES db_owner.country(country_id),

    creation_date               TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by                  VARCHAR(50) NOT NULL,
    last_update_date            TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by             VARCHAR(50) NOT NULL,
    source_system               VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status                 VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version                BIGINT DEFAULT 1 NOT NULL,
    last_synced_at              TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag                CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.administrative_unit OWNER TO db_owner;

COMMENT ON TABLE db_owner.administrative_unit IS
'The table contains information about administrative units from a country';

COMMENT ON COLUMN db_owner.administrative_unit.administrative_unit_id IS 'The id of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.name IS 'The name of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.code IS 'The code of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.population IS 'The population of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.area IS 'The area of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.no_cities IS 'The number of cities of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.description IS 'The description of the administrative unit';
COMMENT ON COLUMN db_owner.administrative_unit.administrative_unit_type_id IS 'The id of the administrative unit type';
COMMENT ON COLUMN db_owner.administrative_unit.country_id IS 'The id of the country';

COMMENT ON COLUMN db_owner.administrative_unit.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.administrative_unit.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.administrative_unit.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.administrative_unit.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.administrative_unit.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.administrative_unit.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.administrative_unit.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.administrative_unit.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.administrative_unit.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_administrative_unit_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_administrative_unit_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.administrative_unit_id IS NULL THEN
        NEW.administrative_unit_id := nextval('db_owner.seq_administrative_unit_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_administrative_unit_id_pk
BEFORE INSERT ON db_owner.administrative_unit
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_administrative_unit_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_administrative_unit_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_administrative_unit_tech_col
BEFORE INSERT OR UPDATE ON db_owner.administrative_unit
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_administrative_unit_tech_col();

ALTER SEQUENCE db_owner.seq_administrative_unit_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_administrative_unit_id
TO db_owner;

\echo '========================';
\echo ' 15. CREATE CITY TABLE  ';
\echo '========================';

CREATE TABLE db_owner.city (
    city_code               BIGINT PRIMARY KEY,
    name                    VARCHAR(100) NOT NULL,
    population              BIGINT NOT NULL,
    area                    BIGINT NOT NULL,
    is_capital              CHAR(1) NOT NULL CHECK (is_capital IN ('Y','N')),
    latitude                NUMERIC(15,9) NOT NULL,
    longitude               NUMERIC(15,9) NOT NULL,
    description             VARCHAR(200),

    administrative_unit_id  BIGINT NOT NULL REFERENCES db_owner.administrative_unit(administrative_unit_id),

    creation_date           TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by              VARCHAR(50) NOT NULL,
    last_update_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by         VARCHAR(50) NOT NULL,
    source_system           VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status             VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version            BIGINT DEFAULT 1 NOT NULL,
    last_synced_at          TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag            CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.city OWNER TO db_owner;

COMMENT ON TABLE db_owner.city IS
'The table contains information about cities such as Bucharest, Paris, Istanbul, etc.';

COMMENT ON COLUMN db_owner.city.city_code IS 'The code of the city';
COMMENT ON COLUMN db_owner.city.name IS 'The name of the city';
COMMENT ON COLUMN db_owner.city.population IS 'The population of the city';
COMMENT ON COLUMN db_owner.city.area IS 'The area of the city';
COMMENT ON COLUMN db_owner.city.is_capital IS 'Flag indicating if the city is a capital';
COMMENT ON COLUMN db_owner.city.latitude IS 'The latitude of the city';
COMMENT ON COLUMN db_owner.city.longitude IS 'The longitude of the city';
COMMENT ON COLUMN db_owner.city.description IS 'The description of the city';
COMMENT ON COLUMN db_owner.city.administrative_unit_id IS 'The administrative unit id of the city';

COMMENT ON COLUMN db_owner.city.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.city.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.city.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.city.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.city.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.city.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.city.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.city.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.city.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_city_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_city_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.city_code IS NULL THEN
        NEW.city_code := nextval('db_owner.seq_city_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_city_code_pk
BEFORE INSERT ON db_owner.city
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_city_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_city_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_city_tech_col
BEFORE INSERT OR UPDATE ON db_owner.city
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_city_tech_col();

ALTER SEQUENCE db_owner.seq_city_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_city_code
TO db_owner;

\echo '===========================';
\echo ' 16. CREATE LOCATION TABLE ';
\echo '===========================';

CREATE TABLE db_owner.location (
    location_id         BIGINT PRIMARY KEY,
    street_name         VARCHAR(100) NOT NULL,
    street_number       VARCHAR(20) NOT NULL,
    postal_code         VARCHAR(20) NOT NULL,
    building            VARCHAR(30),
    staircase           VARCHAR(30),
    floor               VARCHAR(30),
    appartment_number   VARCHAR(30),
    city_code           BIGINT NOT NULL REFERENCES db_owner.city(city_code),

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

ALTER TABLE db_owner.location OWNER TO db_owner;

COMMENT ON TABLE db_owner.location IS
'The table contains information about all the locations in the application. Every user should create their address and assign it to themselves.';

COMMENT ON COLUMN db_owner.location.location_id IS 'The id of the location';
COMMENT ON COLUMN db_owner.location.street_name IS 'The street name of the location';
COMMENT ON COLUMN db_owner.location.street_number IS 'The street number of the location';
COMMENT ON COLUMN db_owner.location.postal_code IS 'The postal code of the location';
COMMENT ON COLUMN db_owner.location.building IS 'The building of the location';
COMMENT ON COLUMN db_owner.location.staircase IS 'The staircase of the location';
COMMENT ON COLUMN db_owner.location.floor IS 'The floor of the location';
COMMENT ON COLUMN db_owner.location.appartment_number IS 'The apartment number of the location';
COMMENT ON COLUMN db_owner.location.city_code IS 'The city code of the location';

COMMENT ON COLUMN db_owner.location.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.location.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.location.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.location.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.location.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.location.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.location.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.location.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.location.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_location_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_location_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.location_id IS NULL THEN
        NEW.location_id := nextval('db_owner.seq_location_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_location_id_pk
BEFORE INSERT ON db_owner.location
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_location_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_location_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_location_tech_col
BEFORE INSERT OR UPDATE ON db_owner.location
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_location_tech_col();

ALTER SEQUENCE db_owner.seq_location_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_location_id
TO db_owner;

\echo '==============================';
\echo ' 17. CREATE INSTITUTION TABLE ';
\echo '==============================';

CREATE TABLE db_owner.institution (
    institution_id      BIGINT PRIMARY KEY,
    name                VARCHAR(200) NOT NULL,
    website             VARCHAR(2000) NOT NULL,
    founding_year       VARCHAR(4) NOT NULL,
    rating              NUMERIC(5,2) DEFAULT 0 NOT NULL,
    profile_picture     BYTEA,
    description         VARCHAR(250),
    location_id         BIGINT REFERENCES db_owner.location(location_id),

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

ALTER TABLE db_owner.institution OWNER TO db_owner;

COMMENT ON TABLE db_owner.institution IS
'The table contains the institutions where the students learned.';

COMMENT ON COLUMN db_owner.institution.institution_id IS 'The id of the institution';
COMMENT ON COLUMN db_owner.institution.name IS 'The name of the institution';
COMMENT ON COLUMN db_owner.institution.website IS 'The website of the institution';
COMMENT ON COLUMN db_owner.institution.founding_year IS 'The founding year of the institution';
COMMENT ON COLUMN db_owner.institution.rating IS 'The rating of the institution';
COMMENT ON COLUMN db_owner.institution.profile_picture IS 'The profile picture of the institution';
COMMENT ON COLUMN db_owner.institution.description IS 'The description of the institution';
COMMENT ON COLUMN db_owner.institution.location_id IS 'The location id of the institution';

COMMENT ON COLUMN db_owner.institution.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.institution.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.institution.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.institution.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.institution.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.institution.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.institution.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.institution.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.institution.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_institution_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_institution_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.institution_id IS NULL THEN
        NEW.institution_id := nextval('db_owner.seq_institution_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_institution_id_pk
BEFORE INSERT ON db_owner.institution
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_institution_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_institution_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_institution_tech_col
BEFORE INSERT OR UPDATE ON db_owner.institution
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_institution_tech_col();

ALTER SEQUENCE db_owner.seq_institution_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_institution_id
TO db_owner;


\echo '======================================';
\echo ' 18. CREATE SPECIALIZATION_TYPE TABLE ';
\echo '======================================';

CREATE TABLE db_owner.specialization_type (
    specialization_type_id BIGINT PRIMARY KEY,
    name                   VARCHAR(100) NOT NULL,
    code                   VARCHAR(50) NOT NULL,
    complexity_score       NUMERIC(5,2) NOT NULL,
    description            VARCHAR(200),

    creation_date          TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by             VARCHAR(50) NOT NULL,
    last_update_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by        VARCHAR(50) NOT NULL,
    source_system          VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status            VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version           BIGINT DEFAULT 1 NOT NULL,
    last_synced_at         TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag           CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.specialization_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.specialization_type IS
'The table contains the specialization types that a student can achieve after graduating an institution';

COMMENT ON COLUMN db_owner.specialization_type.specialization_type_id IS 'The id of the specialization type';
COMMENT ON COLUMN db_owner.specialization_type.name IS 'The name of the specialization type';
COMMENT ON COLUMN db_owner.specialization_type.code IS 'The code of the specialization type';
COMMENT ON COLUMN db_owner.specialization_type.complexity_score IS 'The complexity score of the specialization type';
COMMENT ON COLUMN db_owner.specialization_type.description IS 'The description of the specialization type';

COMMENT ON COLUMN db_owner.specialization_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.specialization_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.specialization_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.specialization_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.specialization_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.specialization_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.specialization_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.specialization_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.specialization_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_specialization_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_specialization_type_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.specialization_type_id IS NULL THEN
        NEW.specialization_type_id := nextval('db_owner.seq_specialization_type_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_specialization_type_id_pk
BEFORE INSERT ON db_owner.specialization_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_specialization_type_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_specialization_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_specialization_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.specialization_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_specialization_type_tech_col();

ALTER SEQUENCE db_owner.seq_specialization_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_specialization_type_id
TO db_owner;

\echo '=================================';
\echo ' 19. CREATE SPECIALIZATION TABLE ';
\echo '=================================';

CREATE TABLE db_owner.specialization (
    specialization_id      BIGINT PRIMARY KEY,
    name                   VARCHAR(200) NOT NULL,
    degree_type            VARCHAR(50) NOT NULL,

    employment_rate        NUMERIC(5,2) NOT NULL,
    teachers_feedback      NUMERIC(5,2) NOT NULL,
    courses_feedback       NUMERIC(5,2) NOT NULL,
    entry_difficulty       NUMERIC(5,2) NOT NULL,
    graduation_difficulty  NUMERIC(5,2) NOT NULL,
    industry_reputation    NUMERIC(5,2) NOT NULL,
    rating                 NUMERIC(5,2) NOT NULL,

    description            VARCHAR(200),

    institution_id         BIGINT NOT NULL REFERENCES db_owner.institution(institution_id),
    specialization_type_id BIGINT NOT NULL REFERENCES db_owner.specialization_type(specialization_type_id),

    creation_date          TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by             VARCHAR(50) NOT NULL,
    last_update_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by        VARCHAR(50) NOT NULL,
    source_system          VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status            VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version           BIGINT DEFAULT 1 NOT NULL,
    last_synced_at         TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag           CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.specialization OWNER TO db_owner;

COMMENT ON TABLE db_owner.specialization IS
'The table contains the specializations of institutions where the students learned.';

COMMENT ON COLUMN db_owner.specialization.specialization_id IS 'The id of the specialization';
COMMENT ON COLUMN db_owner.specialization.name IS 'The name of the specialization';
COMMENT ON COLUMN db_owner.specialization.degree_type IS 'The type of degree obtained after graduation';
COMMENT ON COLUMN db_owner.specialization.description IS 'The description of the specialization';

COMMENT ON COLUMN db_owner.specialization.employment_rate IS 'The employment rate of the specialization';
COMMENT ON COLUMN db_owner.specialization.teachers_feedback IS 'The teachers feedback of the specialization';
COMMENT ON COLUMN db_owner.specialization.courses_feedback IS 'The courses feedback of the specialization';
COMMENT ON COLUMN db_owner.specialization.entry_difficulty IS 'The difficulty to enter this specialization';
COMMENT ON COLUMN db_owner.specialization.graduation_difficulty IS 'The difficulty to finish this specialization';
COMMENT ON COLUMN db_owner.specialization.industry_reputation IS 'The industry reputation of this specialization';
COMMENT ON COLUMN db_owner.specialization.rating IS 'The rating of the specialization';

COMMENT ON COLUMN db_owner.specialization.institution_id IS 'The id of the institution offering this specialization';
COMMENT ON COLUMN db_owner.specialization.specialization_type_id IS 'The id of the specialization type';

COMMENT ON COLUMN db_owner.specialization.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.specialization.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.specialization.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.specialization.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.specialization.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.specialization.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.specialization.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.specialization.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.specialization.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_specialization_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_specialization_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.specialization_id IS NULL THEN
        NEW.specialization_id := nextval('db_owner.seq_specialization_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_specialization_id_pk
BEFORE INSERT ON db_owner.specialization
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_specialization_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_specialization_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_specialization_tech_col
BEFORE INSERT OR UPDATE ON db_owner.specialization
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_specialization_tech_col();

ALTER SEQUENCE db_owner.seq_specialization_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_specialization_id
TO db_owner;

\echo '==============================';
\echo ' 20. CREATE UTILIZATORI TABLE ';
\echo '==============================';

CREATE TABLE db_owner.utilizatori (
    user_id               BIGINT NOT NULL,
    email                 VARCHAR(70) NOT NULL,
    first_name            VARCHAR(50) NOT NULL,
    last_name             VARCHAR(50) NOT NULL,
    user_name             VARCHAR(200) GENERATED ALWAYS AS (
                              initcap(first_name) || initcap(last_name) || user_id
                           ) STORED,
    app_email             VARCHAR(300) GENERATED ALWAYS AS (
                              initcap(first_name) || initcap(last_name) || user_id || '@tech_hunter.com'
                           ) STORED,
    password              VARCHAR(100) NOT NULL,
    date_of_birth         DATE NOT NULL,
    phone                 VARCHAR(20),
    gender                CHAR(1) CHECK (gender IN ('M','F')),

    profile_image         BYTEA,
    profile_document      BYTEA,

    account_status        VARCHAR(20) DEFAULT 'unlocked' NOT NULL CHECK (account_status IN ('unlocked','locked')),
    profile_approved_flag CHAR(1) DEFAULT 'N' NOT NULL CHECK (profile_approved_flag IN ('N','Y')),
    report_sent_flag      CHAR(1) DEFAULT 'N' NOT NULL CHECK (report_sent_flag IN ('N','Y')),
    report_document       BYTEA,

    native_lang_code      BIGINT REFERENCES db_owner.language(lang_code),
    supervizor_id         BIGINT REFERENCES db_owner.utilizatori(user_id),
    location_id           BIGINT REFERENCES db_owner.location(location_id),
    role_id               BIGINT NOT NULL,

    creation_date         TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by            VARCHAR(50) NOT NULL,
    last_update_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by       VARCHAR(50) NOT NULL,

    source_system         VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status           VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version          BIGINT DEFAULT 1 NOT NULL,
    last_synced_at        TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag          CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    -- ⭐ NOILE CÂMPURI PENTRU FORGOT PASSWORD
    reset_token           VARCHAR(255),
    reset_token_expiry    TIMESTAMP,

    CONSTRAINT pk_utilizatori PRIMARY KEY (user_id, email),
    CONSTRAINT uk_utilizatori_user_id UNIQUE (user_id),
    CONSTRAINT uk_utilizatori_email UNIQUE (email)
);

ALTER TABLE db_owner.utilizatori OWNER TO db_owner;

COMMENT ON TABLE db_owner.utilizatori IS
'The table contains the users of the application.';

COMMENT ON COLUMN db_owner.utilizatori.user_id IS 'The primary key of the utilizatori table';
COMMENT ON COLUMN db_owner.utilizatori.email IS 'The primary key of the utilizatori table';
COMMENT ON COLUMN db_owner.utilizatori.first_name IS 'The first name of the user';
COMMENT ON COLUMN db_owner.utilizatori.last_name IS 'The last name of the user';
COMMENT ON COLUMN db_owner.utilizatori.user_name IS 'The application user name of the user';
COMMENT ON COLUMN db_owner.utilizatori.app_email IS 'The email generated by the application';
COMMENT ON COLUMN db_owner.utilizatori.password IS 'The password of the user';
COMMENT ON COLUMN db_owner.utilizatori.date_of_birth IS 'The birth date of the user';
COMMENT ON COLUMN db_owner.utilizatori.phone IS 'The phone number of the user';
COMMENT ON COLUMN db_owner.utilizatori.gender IS 'The gender of the user';
COMMENT ON COLUMN db_owner.utilizatori.profile_image IS 'The profile picture of the user';
COMMENT ON COLUMN db_owner.utilizatori.profile_document IS 'The profile document of the user';
COMMENT ON COLUMN db_owner.utilizatori.account_status IS 'The status of the account';
COMMENT ON COLUMN db_owner.utilizatori.profile_approved_flag IS 'Flag indicating if the profile was approved';
COMMENT ON COLUMN db_owner.utilizatori.report_sent_flag IS 'Flag indicating if the report was sent';
COMMENT ON COLUMN db_owner.utilizatori.report_document IS 'The report document sent by the application';
COMMENT ON COLUMN db_owner.utilizatori.native_lang_code IS 'The native language of the user';
COMMENT ON COLUMN db_owner.utilizatori.supervizor_id IS 'The supervisor id of the user';
COMMENT ON COLUMN db_owner.utilizatori.location_id IS 'The location id of the user';
COMMENT ON COLUMN db_owner.utilizatori.role_id IS 'The role id of the user';

COMMENT ON COLUMN db_owner.utilizatori.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.utilizatori.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.utilizatori.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.utilizatori.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.utilizatori.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.utilizatori.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.utilizatori.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.utilizatori.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.utilizatori.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_user_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_user_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id := nextval('db_owner.seq_user_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_id_pk
BEFORE INSERT ON db_owner.utilizatori
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_user_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_utilizatori_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := COALESCE(NEW.creation_date, NOW());
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NEW.creation_date;
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_utilizatori_tech_col
BEFORE INSERT OR UPDATE ON db_owner.utilizatori
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_utilizatori_tech_col();

ALTER SEQUENCE db_owner.seq_user_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_user_id
TO db_owner;

\echo '========================';
\echo ' 21. CREATE EMAIL TABLE ';
\echo '========================';

CREATE TABLE db_owner.email (
    email_code       BIGINT PRIMARY KEY,
    subject          VARCHAR(250) NOT NULL,
    content          VARCHAR(250),
    attachment       BYTEA,
    arrival_time     TIMESTAMP,
    importance       VARCHAR(50),

    reply_to_email   BIGINT REFERENCES db_owner.email(email_code),
    receiver         BIGINT REFERENCES db_owner.utilizatori(user_id),
    sender           BIGINT REFERENCES db_owner.utilizatori(user_id),

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

ALTER TABLE db_owner.email OWNER TO db_owner;

COMMENT ON TABLE db_owner.email IS
'The table contains the emails exchanged between users in the application';

COMMENT ON COLUMN db_owner.email.email_code IS 'The primary key of the email table';
COMMENT ON COLUMN db_owner.email.subject IS 'The subject of the email';
COMMENT ON COLUMN db_owner.email.content IS 'The content of the email';
COMMENT ON COLUMN db_owner.email.arrival_time IS 'The arrival time of the email';
COMMENT ON COLUMN db_owner.email.importance IS 'The importance of the email';
COMMENT ON COLUMN db_owner.email.reply_to_email IS 'The referenced email code';
COMMENT ON COLUMN db_owner.email.receiver IS 'The receiver of the email';
COMMENT ON COLUMN db_owner.email.sender IS 'The sender of the email';

COMMENT ON COLUMN db_owner.email.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.email.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.email.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.email.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.email.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.email.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.email.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.email.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.email.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_email_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_email_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email_code IS NULL THEN
        NEW.email_code := nextval('db_owner.seq_email_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_email_code_pk
BEFORE INSERT ON db_owner.email
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_email_code_pk();    

CREATE OR REPLACE FUNCTION db_owner.fn_email_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := COALESCE(NEW.creation_date, NOW());
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NEW.creation_date;
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_email_tech_col
BEFORE INSERT OR UPDATE ON db_owner.email
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_email_tech_col();

ALTER SEQUENCE db_owner.seq_email_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_email_code
TO db_owner;

\echo '============================';
\echo ' 22. CREATE USER_SPEC TABLE ';
\echo '============================';

CREATE TABLE db_owner.user_spec (
    specialization_id   BIGINT NOT NULL REFERENCES db_owner.specialization(specialization_id),
    user_id             BIGINT NOT NULL REFERENCES db_owner.utilizatori(user_id),
    graduation_date     DATE,

    creation_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by          VARCHAR(50) NOT NULL,
    last_update_date    TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by     VARCHAR(50) NOT NULL,

    source_system       VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status         VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version        BIGINT DEFAULT 1 NOT NULL,
    last_synced_at      TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag        CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    PRIMARY KEY (specialization_id, user_id)
);

ALTER TABLE db_owner.user_spec OWNER TO db_owner;

COMMENT ON TABLE db_owner.user_spec IS
'The associative table between users and specialization tables.';

COMMENT ON COLUMN db_owner.user_spec.specialization_id IS 'The primary key from specialization table';
COMMENT ON COLUMN db_owner.user_spec.user_id IS 'The primary key from utilizatori table';
COMMENT ON COLUMN db_owner.user_spec.graduation_date IS 'The date when the user graduated the specialization';

COMMENT ON COLUMN db_owner.user_spec.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.user_spec.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.user_spec.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.user_spec.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.user_spec.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.user_spec.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.user_spec.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.user_spec.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.user_spec.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE OR REPLACE FUNCTION db_owner.fn_user_spec_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := COALESCE(NEW.creation_date, NOW());
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NEW.creation_date;
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_spec_tech_col
BEFORE INSERT OR UPDATE ON db_owner.user_spec
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_user_spec_tech_col();

\echo '=============================';
\echo ' 23. CREATE USER_LEVEL TABLE ';
\echo '=============================';

CREATE TABLE db_owner.user_level (
    user_id          BIGINT NOT NULL REFERENCES db_owner.utilizatori(user_id),
    lang_level_id    BIGINT NOT NULL REFERENCES db_owner.lang_level(lang_level_id),
    obtained_date    DATE NOT NULL,

    creation_date    TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by       VARCHAR(50) NOT NULL,
    last_update_date TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by  VARCHAR(50) NOT NULL,

    source_system    VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status      VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version     BIGINT DEFAULT 1 NOT NULL,
    last_synced_at   TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag     CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    PRIMARY KEY (user_id, lang_level_id)
);

ALTER TABLE db_owner.user_level OWNER TO db_owner;

COMMENT ON TABLE db_owner.user_level IS
'The associative table between users and lang_level tables.';

COMMENT ON COLUMN db_owner.user_level.user_id IS 'The primary key from utilizatori table';
COMMENT ON COLUMN db_owner.user_level.lang_level_id IS 'The primary key from lang_level table';
COMMENT ON COLUMN db_owner.user_level.obtained_date IS 'The date when the user obtained the certification';

COMMENT ON COLUMN db_owner.user_level.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.user_level.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.user_level.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.user_level.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.user_level.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.user_level.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.user_level.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.user_level.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.user_level.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE OR REPLACE FUNCTION db_owner.fn_user_level_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := COALESCE(NEW.creation_date, NOW());
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NEW.creation_date;
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_level_tech_col
BEFORE INSERT OR UPDATE ON db_owner.user_level
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_user_level_tech_col();

\echo '=============================';
\echo ' 24. CREATE USER_SKILL TABLE ';
\echo '=============================';

CREATE TABLE db_owner.user_skill (
    user_id            BIGINT NOT NULL REFERENCES db_owner.utilizatori(user_id),
    skill_code         BIGINT NOT NULL REFERENCES db_owner.skill(skill_code),

    proficiency_level  NUMERIC(5,2) NOT NULL,
    experience_months  INTEGER NOT NULL,
    last_used_date     DATE NOT NULL,
    confidence_score   NUMERIC(5,2),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    PRIMARY KEY (user_id, skill_code)
);

ALTER TABLE db_owner.user_skill OWNER TO db_owner;

COMMENT ON TABLE db_owner.user_skill IS
'The associative table between users and skill tables.';

COMMENT ON COLUMN db_owner.user_skill.user_id IS 'The primary key from utilizatori table';
COMMENT ON COLUMN db_owner.user_skill.skill_code IS 'The code of the skill';
COMMENT ON COLUMN db_owner.user_skill.proficiency_level IS 'The proficiency level of the skill';
COMMENT ON COLUMN db_owner.user_skill.experience_months IS 'The number of months the user worked with the skill';
COMMENT ON COLUMN db_owner.user_skill.last_used_date IS 'The last date when the user used the skill';
COMMENT ON COLUMN db_owner.user_skill.confidence_score IS 'The confidence score assigned by HR';

COMMENT ON COLUMN db_owner.user_skill.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.user_skill.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.user_skill.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.user_skill.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.user_skill.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.user_skill.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.user_skill.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.user_skill.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.user_skill.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE OR REPLACE FUNCTION db_owner.fn_user_skill_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := COALESCE(NEW.creation_date, NOW());
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NEW.creation_date;
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_skill_tech_col
BEFORE INSERT OR UPDATE ON db_owner.user_skill
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_user_skill_tech_col();

\echo '====================================';
\echo ' 25. CREATE ORGANIZATION_TYPE TABLE ';
\echo '====================================';

CREATE TABLE db_owner.organization_type (
    company_type_id     BIGINT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    code                VARCHAR(50) NOT NULL,
    description         VARCHAR(200),

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

ALTER TABLE db_owner.organization_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.organization_type IS
'The table contains the types of organizations';

COMMENT ON COLUMN db_owner.organization_type.company_type_id IS 'The id of the organization type';
COMMENT ON COLUMN db_owner.organization_type.name IS 'The name of the organization type';
COMMENT ON COLUMN db_owner.organization_type.code IS 'The code of the organization type';
COMMENT ON COLUMN db_owner.organization_type.description IS 'The description of the organization type';

COMMENT ON COLUMN db_owner.organization_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.organization_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.organization_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.organization_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.organization_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.organization_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.organization_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.organization_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.organization_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_company_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_company_type_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.company_type_id IS NULL THEN
        NEW.company_type_id := nextval('db_owner.seq_company_type_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_company_type_id_pk
BEFORE INSERT ON db_owner.organization_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_company_type_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_organization_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_organization_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.organization_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_organization_type_tech_col();

ALTER SEQUENCE db_owner.seq_company_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_company_type_id
TO db_owner;

\echo '================================';
\echo ' 26. CREATE INDUSTRY_TYPE TABLE ';
\echo '================================';

CREATE TABLE db_owner.industry_type (
    industry_type_id   BIGINT PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    code               VARCHAR(50) NOT NULL,
    description        VARCHAR(200),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.industry_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.industry_type IS
'The table contains the types of industry';

COMMENT ON COLUMN db_owner.industry_type.industry_type_id IS 'The id of the industry';
COMMENT ON COLUMN db_owner.industry_type.name IS 'The name of the industry';
COMMENT ON COLUMN db_owner.industry_type.code IS 'The code of the industry';
COMMENT ON COLUMN db_owner.industry_type.description IS 'The description of the industry';

COMMENT ON COLUMN db_owner.industry_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.industry_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.industry_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.industry_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.industry_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.industry_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.industry_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.industry_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.industry_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_industry_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_industry_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_industry_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.industry_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_industry_type_tech_col();

ALTER SEQUENCE db_owner.seq_industry_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_industry_type_id
TO db_owner;

\echo '==================================';
\echo ' 27. CREATE DEPARTMENT_TYPE TABLE ';
\echo '==================================';

CREATE TABLE db_owner.department_type (
    department_type_id  BIGINT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    code                VARCHAR(50) NOT NULL,
    description         VARCHAR(200),

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

ALTER TABLE db_owner.department_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.department_type IS
'This table contains the types of departments that a company could have. Examples: Human Resources, Data Analytics and AI, etc.';

COMMENT ON COLUMN db_owner.department_type.department_type_id IS 'The id of the department type';
COMMENT ON COLUMN db_owner.department_type.name IS 'The name of the department type';
COMMENT ON COLUMN db_owner.department_type.code IS 'The code of the department type';
COMMENT ON COLUMN db_owner.department_type.description IS 'The description of the department type';

COMMENT ON COLUMN db_owner.department_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.department_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.department_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.department_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.department_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.department_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.department_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.department_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.department_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_department_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_department_type_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.department_type_id IS NULL THEN
        NEW.department_type_id := nextval('db_owner.seq_department_type_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_department_type_id_pk
BEFORE INSERT ON db_owner.department_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_department_type_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_department_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_department_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.department_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_department_type_tech_col();

ALTER SEQUENCE db_owner.seq_department_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_department_type_id
TO db_owner;

\echo '==================================';
\echo ' 28. CREATE EMPLOYMENT_TYPE TABLE ';
\echo '==================================';

CREATE TABLE db_owner.employment_type (
    employment_type_id  BIGINT PRIMARY KEY,
    name                VARCHAR(50) NOT NULL,
    complexity_score    NUMERIC(5,2) NOT NULL,
    code                VARCHAR(50) NOT NULL,
    description         VARCHAR(200),

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

ALTER TABLE db_owner.employment_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.employment_type IS
'The table contains all the employment types you can have on a job. Examples: Internship, Part-Time, Full-Time, Unlimited, etc.';

COMMENT ON COLUMN db_owner.employment_type.employment_type_id IS 'The id of the employment type';
COMMENT ON COLUMN db_owner.employment_type.name IS 'The name of the employment type';
COMMENT ON COLUMN db_owner.employment_type.complexity_score IS 'The complexity score of the employment type';
COMMENT ON COLUMN db_owner.employment_type.code IS 'The code of the employment type';
COMMENT ON COLUMN db_owner.employment_type.description IS 'The description of the employment type';

COMMENT ON COLUMN db_owner.employment_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.employment_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.employment_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.employment_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.employment_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.employment_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.employment_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.employment_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.employment_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_employment_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_employment_type_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.employment_type_id IS NULL THEN
        NEW.employment_type_id := nextval('db_owner.seq_employment_type_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_employment_type_id_pk
BEFORE INSERT ON db_owner.employment_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_employment_type_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_employment_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_employment_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.employment_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_employment_type_tech_col();

ALTER SEQUENCE db_owner.seq_employment_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_employment_type_id
TO db_owner;

\echo '============================';
\echo ' 29. CREATE WORK_TYPE TABLE ';
\echo '============================';

CREATE TABLE db_owner.work_type (
    work_type_id       BIGINT PRIMARY KEY,
    name               VARCHAR(50) NOT NULL,
    complexity_score   NUMERIC(5,2) NOT NULL,
    code               VARCHAR(50) NOT NULL,
    description        VARCHAR(200),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.work_type OWNER TO db_owner;

COMMENT ON TABLE db_owner.work_type IS
'The table contains all the work types you can have on a job';

COMMENT ON COLUMN db_owner.work_type.work_type_id IS 'The id of the work type';
COMMENT ON COLUMN db_owner.work_type.name IS 'The name of the work type';
COMMENT ON COLUMN db_owner.work_type.complexity_score IS 'The complexity score of the work type';
COMMENT ON COLUMN db_owner.work_type.code IS 'The code of the work type';
COMMENT ON COLUMN db_owner.work_type.description IS 'The description of the work type';

COMMENT ON COLUMN db_owner.work_type.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.work_type.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.work_type.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.work_type.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.work_type.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.work_type.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.work_type.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.work_type.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.work_type.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_work_type_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_work_type_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.work_type_id IS NULL THEN
        NEW.work_type_id := nextval('db_owner.seq_work_type_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_work_type_id_pk
BEFORE INSERT ON db_owner.work_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_work_type_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_work_type_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_work_type_tech_col
BEFORE INSERT OR UPDATE ON db_owner.work_type
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_work_type_tech_col();

ALTER SEQUENCE db_owner.seq_work_type_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_work_type_id
TO db_owner;

\echo '===============================';
\echo ' 30. CREATE JOB_CATEGORY TABLE ';
\echo '===============================';

CREATE TABLE db_owner.job_category (
    job_category_id    BIGINT PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    complexity_score   NUMERIC(5,2) NOT NULL,
    code               VARCHAR(50) NOT NULL,
    description        VARCHAR(200),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.job_category OWNER TO db_owner;

COMMENT ON TABLE db_owner.job_category IS
'The table contains all the job categories you can have on a job';

COMMENT ON COLUMN db_owner.job_category.job_category_id IS 'The id of the job category';
COMMENT ON COLUMN db_owner.job_category.name IS 'The name of the job category';
COMMENT ON COLUMN db_owner.job_category.complexity_score IS 'The complexity score of the job category';
COMMENT ON COLUMN db_owner.job_category.code IS 'The code of the job category';
COMMENT ON COLUMN db_owner.job_category.description IS 'The description of the job category';

COMMENT ON COLUMN db_owner.job_category.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.job_category.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.job_category.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.job_category.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.job_category.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.job_category.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.job_category.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.job_category.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.job_category.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_job_category_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_job_category_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.job_category_id IS NULL THEN
        NEW.job_category_id := nextval('db_owner.seq_job_category_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_category_id_pk
BEFORE INSERT ON db_owner.job_category
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_category_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_job_category_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_category_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job_category
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_category_tech_col();

ALTER SEQUENCE db_owner.seq_job_category_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_job_category_id
TO db_owner;

\echo '============================';
\echo ' 31. CREATE JOB_TITLE TABLE ';
\echo '============================';

CREATE TABLE db_owner.job_title (
    job_title_id       BIGINT PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    complexity_score   NUMERIC(5,2) NOT NULL,
    code               VARCHAR(50) NOT NULL,
    description        VARCHAR(200),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.job_title OWNER TO db_owner;

COMMENT ON TABLE db_owner.job_title IS
'The table contains all the job titles you can have on a job';

COMMENT ON COLUMN db_owner.job_title.job_title_id IS 'The id of the job title';
COMMENT ON COLUMN db_owner.job_title.name IS 'The name of the job title';
COMMENT ON COLUMN db_owner.job_title.complexity_score IS 'The complexity score of the job title';
COMMENT ON COLUMN db_owner.job_title.code IS 'The code of the job title';
COMMENT ON COLUMN db_owner.job_title.description IS 'The description of the job title';

COMMENT ON COLUMN db_owner.job_title.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.job_title.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.job_title.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.job_title.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.job_title.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.job_title.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.job_title.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.job_title.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.job_title.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_job_title_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_job_title_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.job_title_id IS NULL THEN
        NEW.job_title_id := nextval('db_owner.seq_job_title_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_title_id_pk
BEFORE INSERT ON db_owner.job_title
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_title_id_pk();   

CREATE OR REPLACE FUNCTION db_owner.fn_job_title_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_title_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job_title
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_title_tech_col();

ALTER SEQUENCE db_owner.seq_job_title_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_job_title_id
TO db_owner;

\echo '============================';
\echo ' 32. CREATE JOB_LEVEL TABLE ';
\echo '============================';

CREATE TABLE db_owner.job_level (
    job_level_id       BIGINT PRIMARY KEY,
    name               VARCHAR(50) NOT NULL,
    complexity_score   NUMERIC(5,2) NOT NULL,
    code               VARCHAR(50) NOT NULL,
    description        VARCHAR(200),

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
);

ALTER TABLE db_owner.job_level OWNER TO db_owner;

COMMENT ON TABLE db_owner.job_level IS
'The table contains all the levels you can have on a job';

COMMENT ON COLUMN db_owner.job_level.job_level_id IS 'The id of the job level';
COMMENT ON COLUMN db_owner.job_level.name IS 'The name of the job level';
COMMENT ON COLUMN db_owner.job_level.complexity_score IS 'The complexity score of the job level';
COMMENT ON COLUMN db_owner.job_level.code IS 'The code of the job level';
COMMENT ON COLUMN db_owner.job_level.description IS 'The description of the job level';

COMMENT ON COLUMN db_owner.job_level.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN db_owner.job_level.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.job_level.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN db_owner.job_level.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.job_level.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN db_owner.job_level.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN db_owner.job_level.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN db_owner.job_level.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN db_owner.job_level.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

CREATE SEQUENCE db_owner.seq_job_level_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_job_level_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.job_level_id IS NULL THEN
        NEW.job_level_id := nextval('db_owner.seq_job_level_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_level_id_pk
BEFORE INSERT ON db_owner.job_level
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_level_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_job_level_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_level_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job_level
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_level_tech_col();

--la finalul scriptului pentru tabela
ALTER SEQUENCE db_owner.seq_job_level_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_job_level_id
TO db_owner;

\echo '==========================';
\echo ' 33. CREATE COMPANY TABLE ';
\echo '==========================';

CREATE TABLE db_owner.company (
    company_id              BIGINT NOT NULL,
    legal_entity_identifier VARCHAR(50) NOT NULL,
    name                    VARCHAR(255) NOT NULL,
    trade_register_number   VARCHAR(50) NOT NULL,
    website                 VARCHAR(255) NOT NULL,
    foundation_date         DATE NOT NULL,
    no_employees            BIGINT NOT NULL,
    description             VARCHAR(200) NOT NULL,
    sign_image              BYTEA,
    profile_image           BYTEA,
    share_capital           NUMERIC(15,2) NOT NULL,
    net_profit              BIGINT NOT NULL,
    average_annual_revenue  BIGINT NOT NULL,
    total_assets            BIGINT NOT NULL,
    total_liabilities       BIGINT NOT NULL,
    debt_to_equity_ratio    BIGINT NOT NULL,

    rating NUMERIC(5,2) GENERATED ALWAYS AS (
        LEAST(
            GREATEST(
                ROUND(
                    (
                        0.2588 * LEAST(GREATEST(COALESCE(net_profit::numeric / NULLIF(average_annual_revenue,0),0),0),1) +
                        0.2118 * LEAST(GREATEST(COALESCE((total_assets-total_liabilities)::numeric / NULLIF(total_assets,0),0),0),1) +
                        0.1412 * LEAST(GREATEST(1 - (COALESCE(debt_to_equity_ratio,0)::numeric / 10),0),1) +
                        0.2118 * LEAST(GREATEST(COALESCE(net_profit::numeric / NULLIF(no_employees,0),0) / 1000,0),1) +
                        0.1765 * LEAST(GREATEST(COALESCE(share_capital::numeric / NULLIF(total_assets,0),0),0),1)
                    ) * 100
                ,2)
            ,0)
        ,100)
    ) STORED,

    user_id             BIGINT NOT NULL,
    user_email          VARCHAR(70) NOT NULL,
    industry_type_id    BIGINT NOT NULL,
    company_type_id     BIGINT NOT NULL,
    company_location_id BIGINT NOT NULL,
    currency_code       BIGINT NOT NULL,

    creation_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by          VARCHAR(50) NOT NULL,
    last_update_date    TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by     VARCHAR(50) NOT NULL,
    source_system       VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status         VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version        BIGINT DEFAULT 1 NOT NULL,
    last_synced_at      TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag        CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT uq_company_company_id UNIQUE (company_id),
    CONSTRAINT pk_company PRIMARY KEY (company_id, legal_entity_identifier),

    CONSTRAINT fk_company_user_id FOREIGN KEY (user_id) REFERENCES db_owner.utilizatori(user_id),
    CONSTRAINT fk_company_user_email FOREIGN KEY (user_email) REFERENCES db_owner.utilizatori(email),
    CONSTRAINT fk_company_industry_type FOREIGN KEY (industry_type_id) REFERENCES db_owner.industry_type(industry_type_id),
    CONSTRAINT fk_company_company_type FOREIGN KEY (company_type_id) REFERENCES db_owner.organization_type(company_type_id),
    CONSTRAINT fk_company_location FOREIGN KEY (company_location_id) REFERENCES db_owner.location(location_id),
    CONSTRAINT fk_company_currency FOREIGN KEY (currency_code) REFERENCES db_owner.currency(currency_code)
);

ALTER TABLE db_owner.company OWNER TO db_owner;

COMMENT ON TABLE db_owner.company IS
'The table contains all the information about companies in the application.';

COMMENT ON COLUMN db_owner.company.company_id IS 'The id of the company';
COMMENT ON COLUMN db_owner.company.legal_entity_identifier IS 'The legal entity identifier of the company';
COMMENT ON COLUMN db_owner.company.name IS 'The name of the company';
COMMENT ON COLUMN db_owner.company.trade_register_number IS 'The trade register number of the company';
COMMENT ON COLUMN db_owner.company.website IS 'The website of the company';
COMMENT ON COLUMN db_owner.company.foundation_date IS 'The foundation date of the company';
COMMENT ON COLUMN db_owner.company.no_employees IS 'The number of employees';
COMMENT ON COLUMN db_owner.company.description IS 'The description of the company';
COMMENT ON COLUMN db_owner.company.sign_image IS 'The sign image of the company';
COMMENT ON COLUMN db_owner.company.profile_image IS 'The profile image of the company';
COMMENT ON COLUMN db_owner.company.share_capital IS 'The share capital of the company';
COMMENT ON COLUMN db_owner.company.net_profit IS 'The net profit of the company';
COMMENT ON COLUMN db_owner.company.average_annual_revenue IS 'The average annual revenue';
COMMENT ON COLUMN db_owner.company.total_assets IS 'The total assets';
COMMENT ON COLUMN db_owner.company.total_liabilities IS 'The total liabilities';
COMMENT ON COLUMN db_owner.company.debt_to_equity_ratio IS 'The debt to equity ratio';
COMMENT ON COLUMN db_owner.company.rating IS 'The computed rating of the company';

COMMENT ON COLUMN db_owner.company.user_id IS 'The id of the user who registered the company';
COMMENT ON COLUMN db_owner.company.user_email IS 'The email of the user who registered the company';
COMMENT ON COLUMN db_owner.company.industry_type_id IS 'The industry type id';
COMMENT ON COLUMN db_owner.company.company_type_id IS 'The company type id';
COMMENT ON COLUMN db_owner.company.company_location_id IS 'The company location id';
COMMENT ON COLUMN db_owner.company.currency_code IS 'The currency code used for rating calculations';

COMMENT ON COLUMN db_owner.company.creation_date IS 'Technical Column - The creation date';
COMMENT ON COLUMN db_owner.company.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN db_owner.company.last_update_date IS 'Technical Column - The last update date';
COMMENT ON COLUMN db_owner.company.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN db_owner.company.source_system IS 'Technical Column - The source system';
COMMENT ON COLUMN db_owner.company.sync_status IS 'Technical Column - The sync status';
COMMENT ON COLUMN db_owner.company.sync_version IS 'Technical Column - The sync version';
COMMENT ON COLUMN db_owner.company.last_synced_at IS 'Technical Column - Last sync timestamp';
COMMENT ON COLUMN db_owner.company.deleted_flag IS 'Technical Column - Soft delete flag';

CREATE SEQUENCE db_owner.seq_company_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_company_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.company_id IS NULL THEN
        NEW.company_id := nextval('db_owner.seq_company_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_company_id_pk
BEFORE INSERT ON db_owner.company
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_company_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_company_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_company_tech_col
BEFORE INSERT OR UPDATE ON db_owner.company
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_company_tech_col();

ALTER SEQUENCE db_owner.seq_company_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_company_id
TO db_owner;

\echo '=============================';
\echo ' 34. CREATE DEPARTMENT TABLE ';
\echo '=============================';

CREATE TABLE db_owner.department (
    department_id        BIGINT PRIMARY KEY,
    description          VARCHAR(100) NOT NULL,
    annual_budget        BIGINT NOT NULL,
    operational_costs    BIGINT NOT NULL,
    expenses             NUMERIC(15,2) NOT NULL,
    revenue_generated    NUMERIC(15,2) NOT NULL,
    no_employees         BIGINT NOT NULL,
    avg_salary           NUMERIC(15,2) NOT NULL,
    growth_potential     NUMERIC(5,2) NOT NULL,
    training_budget      NUMERIC(15,2) NOT NULL,
    no_open_positions    BIGINT,
    turnover_rate        NUMERIC(5,2) NOT NULL,

    rating NUMERIC(5,2) GENERATED ALWAYS AS (
        LEAST(
            GREATEST(
                ROUND(
                    (
                        0.20 * COALESCE(1 - (operational_costs::numeric / NULLIF(annual_budget,0)),0) +
                        0.20 * COALESCE(revenue_generated / NULLIF(expenses,0),0) +
                        0.10 * COALESCE(1 - (avg_salary / 10000),0) +
                        0.15 * COALESCE(growth_potential / 100,0) +
                        0.10 * COALESCE(training_budget / NULLIF(annual_budget,0),0) +
                        0.10 * COALESCE(1 - (no_open_positions::numeric / NULLIF(no_employees,0)),0) +
                        0.15 * COALESCE(1 - (turnover_rate / 100),0)
                    ) * 100
                ,2)
            ,0)
        ,100)
    ) STORED,

    company_id           BIGINT NOT NULL,
    department_type_code BIGINT NOT NULL,

    creation_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by           VARCHAR(50) NOT NULL,
    last_update_date     TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by      VARCHAR(50) NOT NULL,

    source_system        VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status          VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version         BIGINT DEFAULT 1 NOT NULL,
    last_synced_at       TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag         CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_department_company FOREIGN KEY (company_id)
        REFERENCES db_owner.company(company_id),

    CONSTRAINT fk_department_type FOREIGN KEY (department_type_code)
        REFERENCES db_owner.department_type(department_type_id)
);

ALTER TABLE db_owner.department OWNER TO db_owner;

COMMENT ON TABLE db_owner.department IS
'The table contains all department information for each company.';

COMMENT ON COLUMN db_owner.department.department_id IS 'The id of the department';
COMMENT ON COLUMN db_owner.department.description IS 'The description of the department';
COMMENT ON COLUMN db_owner.department.annual_budget IS 'The annual budget of the department';
COMMENT ON COLUMN db_owner.department.operational_costs IS 'The operational costs of the department';
COMMENT ON COLUMN db_owner.department.expenses IS 'The expenses of the department';
COMMENT ON COLUMN db_owner.department.revenue_generated IS 'The revenue generated by the department';
COMMENT ON COLUMN db_owner.department.no_employees IS 'The number of employees in the department';
COMMENT ON COLUMN db_owner.department.avg_salary IS 'The average salary in the department';
COMMENT ON COLUMN db_owner.department.growth_potential IS 'The growth potential of the department';
COMMENT ON COLUMN db_owner.department.training_budget IS 'The training budget of the department';
COMMENT ON COLUMN db_owner.department.no_open_positions IS 'The number of open positions';
COMMENT ON COLUMN db_owner.department.turnover_rate IS 'The turnover rate of the department';
COMMENT ON COLUMN db_owner.department.rating IS 'The computed rating of the department';

COMMENT ON COLUMN db_owner.department.company_id IS 'The company owning the department';
COMMENT ON COLUMN db_owner.department.department_type_code IS 'The department type code';

COMMENT ON COLUMN db_owner.department.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.department.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.department.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.department.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.department.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.department.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.department.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.department.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.department.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_department_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_department_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.department_id IS NULL THEN
        NEW.department_id := nextval('db_owner.seq_department_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_department_id_pk
BEFORE INSERT ON db_owner.department
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_department_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_department_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_department_tech_col
BEFORE INSERT OR UPDATE ON db_owner.department
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_department_tech_col();

--la finalul scriptului pentru tabela
ALTER SEQUENCE db_owner.seq_department_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_department_id
TO db_owner;

\echo '======================';
\echo ' 35. CREATE JOB TABLE ';
\echo '======================';

CREATE TABLE db_owner.job (
    job_id              BIGINT PRIMARY KEY,
    description         VARCHAR(200) NOT NULL,
    requirements        VARCHAR(500) NOT NULL,
    responsabilities    VARCHAR(300) NOT NULL,
    benefits            VARCHAR(300),
    salary_min          BIGINT NOT NULL,
    salary_max          BIGINT,
    hire_date           DATE NOT NULL,
    expiry_date         DATE,
    employment_period   BIGINT,
    demand_score        NUMERIC(5,2) NOT NULL,
    complexity_score    NUMERIC(5,2) DEFAULT 0 NOT NULL,
    employees_rating    NUMERIC(5,2) DEFAULT 0 NOT NULL,

    job_status          VARCHAR(50) NOT NULL,
    department_id       BIGINT NOT NULL,
    employment_type_id  BIGINT NOT NULL,
    work_type_id        BIGINT NOT NULL,
    job_title_id        BIGINT NOT NULL,
    job_level_id        BIGINT NOT NULL,
    job_category_id     BIGINT NOT NULL,
    currency_code       BIGINT NOT NULL,
    location_id         BIGINT NOT NULL,

    creation_date       TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by          VARCHAR(50) NOT NULL,
    last_update_date    TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by     VARCHAR(50) NOT NULL,

    source_system       VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status         VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version        BIGINT DEFAULT 1 NOT NULL,
    last_synced_at      TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag        CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_job_department_id      FOREIGN KEY (department_id)      REFERENCES db_owner.department(department_id),
    CONSTRAINT fk_job_employment_type_id FOREIGN KEY (employment_type_id) REFERENCES db_owner.employment_type(employment_type_id),
    CONSTRAINT fk_job_work_type_id       FOREIGN KEY (work_type_id)       REFERENCES db_owner.work_type(work_type_id),
    CONSTRAINT fk_job_job_title_id       FOREIGN KEY (job_title_id)       REFERENCES db_owner.job_title(job_title_id),
    CONSTRAINT fk_job_job_level_id       FOREIGN KEY (job_level_id)       REFERENCES db_owner.job_level(job_level_id),
    CONSTRAINT fk_job_job_category_id    FOREIGN KEY (job_category_id)    REFERENCES db_owner.job_category(job_category_id),
    CONSTRAINT fk_job_currency_code      FOREIGN KEY (currency_code)      REFERENCES db_owner.currency(currency_code),
    CONSTRAINT fk_job_location_id        FOREIGN KEY (location_id)        REFERENCES db_owner.location(location_id)
);

ALTER TABLE db_owner.job OWNER TO db_owner;

COMMENT ON TABLE db_owner.job IS 'The table contains all job postings in the application';

COMMENT ON COLUMN db_owner.job.job_id IS 'The id of the job';
COMMENT ON COLUMN db_owner.job.description IS 'The description of the job';
COMMENT ON COLUMN db_owner.job.requirements IS 'The requirements of the job';
COMMENT ON COLUMN db_owner.job.responsabilities IS 'The responsibilities of the job';
COMMENT ON COLUMN db_owner.job.benefits IS 'The benefits of the job';
COMMENT ON COLUMN db_owner.job.salary_min IS 'The minimum salary';
COMMENT ON COLUMN db_owner.job.salary_max IS 'The maximum salary';
COMMENT ON COLUMN db_owner.job.hire_date IS 'The hire date';
COMMENT ON COLUMN db_owner.job.expiry_date IS 'The expiry date';
COMMENT ON COLUMN db_owner.job.employment_period IS 'The employment period';
COMMENT ON COLUMN db_owner.job.demand_score IS 'The demand score';
COMMENT ON COLUMN db_owner.job.complexity_score IS 'The computed complexity score';
COMMENT ON COLUMN db_owner.job.employees_rating IS 'The employees rating';
COMMENT ON COLUMN db_owner.job.job_status IS 'The status of the job';
COMMENT ON COLUMN db_owner.job.department_id IS 'The department id';
COMMENT ON COLUMN db_owner.job.employment_type_id IS 'The employment type id';
COMMENT ON COLUMN db_owner.job.work_type_id IS 'The work type id';
COMMENT ON COLUMN db_owner.job.job_title_id IS 'The job title id';
COMMENT ON COLUMN db_owner.job.job_level_id IS 'The job level id';
COMMENT ON COLUMN db_owner.job.job_category_id IS 'The job category id';
COMMENT ON COLUMN db_owner.job.currency_code IS 'The currency code';
COMMENT ON COLUMN db_owner.job.location_id IS 'The location id';

COMMENT ON COLUMN db_owner.job.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.job.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.job.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.job.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.job.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.job.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.job.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.job.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.job.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_job_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_job_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.job_id IS NULL THEN
        NEW.job_id := nextval('db_owner.seq_job_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_id_pk
BEFORE INSERT ON db_owner.job
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_job_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_tech_col();

CREATE OR REPLACE FUNCTION db_owner.fn_job_complexity_score_sync()
RETURNS TRIGGER AS $$
DECLARE
    v_cat_score          NUMERIC := 0;
    v_title_score        NUMERIC := 0;
    v_level_score        NUMERIC := 0;
    v_work_score         NUMERIC := 0;
    v_employment_score   NUMERIC := 0;

    v_skill_complexity   NUMERIC := 0;
    v_language_complexity NUMERIC := 0;
    v_degree_complexity   NUMERIC := 0;
BEGIN
    SELECT COALESCE(complexity_score,0)
    INTO v_cat_score
    FROM db_owner.job_category
    WHERE job_category_id = NEW.job_category_id;

    SELECT COALESCE(complexity_score,0)
    INTO v_title_score
    FROM db_owner.job_title
    WHERE job_title_id = NEW.job_title_id;

    SELECT COALESCE(complexity_score,0)
    INTO v_level_score
    FROM db_owner.job_level
    WHERE job_level_id = NEW.job_level_id;

    SELECT COALESCE(complexity_score,0)
    INTO v_work_score
    FROM db_owner.work_type
    WHERE work_type_id = NEW.work_type_id;

    SELECT COALESCE(complexity_score,0)
    INTO v_employment_score
    FROM db_owner.employment_type
    WHERE employment_type_id = NEW.employment_type_id;

    SELECT COALESCE(AVG(
        (COALESCE(s.rating,0)
       + COALESCE(v.skills_rating,0)
       + COALESCE(t.rating,0)
       + COALESCE(tt.rating,0)) / 4
    ),0)
    INTO v_skill_complexity
    FROM db_owner.job_skill js
    JOIN db_owner.skill s ON s.skill_code = js.skill_code
    LEFT JOIN db_owner.version v ON v.version_code = s.last_version_code
    LEFT JOIN db_owner.technology t ON t.technology_code = v.technology_code
    LEFT JOIN db_owner.technology_type tt ON tt.technology_type_code = t.technology_type_code
    WHERE js.job_id = NEW.job_id;

    SELECT COALESCE(AVG(
        (COALESCE(l.rating,0)
       + COALESCE(ll.rating,0)) / 2
    ),0)
    INTO v_language_complexity
    FROM db_owner.language_requirement lr
    JOIN db_owner.language l ON l.lang_code = lr.lang_code
    JOIN db_owner.lang_level ll ON ll.lang_level_id = lr.lang_level_id
    WHERE lr.job_id = NEW.job_id;

    SELECT COALESCE(AVG(
        (COALESCE(st.complexity_score,0)
       + COALESCE(i.rating,0)) / 2
    ),0)
    INTO v_degree_complexity
    FROM db_owner.degree_requirement dr
    JOIN db_owner.specialization_type st ON st.specialization_type_id = dr.specialization_type_code
    JOIN db_owner.institution i ON i.institution_id = dr.institution_id
    WHERE dr.job_id = NEW.job_id;

    NEW.complexity_score :=
        LEAST(
            0.10 * v_cat_score +
            0.10 * v_title_score +
            0.15 * v_level_score +
            0.10 * v_work_score +
            0.10 * v_employment_score +
            0.15 * v_skill_complexity +
            0.10 * v_language_complexity +
            0.10 * v_degree_complexity +
            0.10 * LEAST(COALESCE(NEW.employees_rating,0),100),
        100);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_complexity_score_sync
BEFORE INSERT OR UPDATE ON db_owner.job
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_complexity_score_sync();

ALTER SEQUENCE db_owner.seq_job_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_job_id
TO db_owner;

\echo '======================================';
\echo ' 36. CREATE DEGREE_REQUIREMENTS TABLE ';
\echo '======================================';

CREATE TABLE db_owner.degree_requirement (
    degree_requirement_code   BIGINT PRIMARY KEY,
    priority                  INTEGER NOT NULL,
    importance                VARCHAR(20) NOT NULL,
    degree_type               VARCHAR(20) NOT NULL,
    graduation_required       CHAR(1),
    description               VARCHAR(100),

    job_id                    BIGINT NOT NULL,
    specialization_type_code  BIGINT NOT NULL,
    institution_id            BIGINT NOT NULL,

    creation_date             TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by                VARCHAR(50) NOT NULL,
    last_update_date          TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by           VARCHAR(50) NOT NULL,

    source_system             VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status               VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version              BIGINT DEFAULT 1 NOT NULL,
    last_synced_at            TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag              CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_degree_req_job FOREIGN KEY (job_id)
        REFERENCES db_owner.job(job_id),

    CONSTRAINT fk_degree_req_specialization FOREIGN KEY (specialization_type_code)
        REFERENCES db_owner.specialization_type(specialization_type_id),

    CONSTRAINT fk_degree_req_institution FOREIGN KEY (institution_id)
        REFERENCES db_owner.institution(institution_id)
);

ALTER TABLE db_owner.degree_requirement OWNER TO db_owner;

COMMENT ON TABLE db_owner.degree_requirement IS
'Degree requirements associated with a job posting.';

COMMENT ON COLUMN db_owner.degree_requirement.degree_requirement_code IS 'The code of the degree requirement';
COMMENT ON COLUMN db_owner.degree_requirement.priority IS 'The priority of the degree requirement';
COMMENT ON COLUMN db_owner.degree_requirement.importance IS 'The importance of the degree requirement';
COMMENT ON COLUMN db_owner.degree_requirement.degree_type IS 'The type of the degree requirement';
COMMENT ON COLUMN db_owner.degree_requirement.graduation_required IS 'Flag indicating if graduation is required';
COMMENT ON COLUMN db_owner.degree_requirement.description IS 'Description of the degree requirement';

COMMENT ON COLUMN db_owner.degree_requirement.job_id IS 'The job id';
COMMENT ON COLUMN db_owner.degree_requirement.specialization_type_code IS 'The specialization type code';
COMMENT ON COLUMN db_owner.degree_requirement.institution_id IS 'The institution id';

COMMENT ON COLUMN db_owner.degree_requirement.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.degree_requirement.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.degree_requirement.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.degree_requirement.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.degree_requirement.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.degree_requirement.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.degree_requirement.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.degree_requirement.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.degree_requirement.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_degree_requirement_code
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_degree_requirement_code_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.degree_requirement_code IS NULL THEN
        NEW.degree_requirement_code := nextval('db_owner.seq_degree_requirement_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_degree_requirement_code_pk
BEFORE INSERT ON db_owner.degree_requirement
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_degree_requirement_code_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_degree_requirement_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_degree_requirement_tech_col
BEFORE INSERT OR UPDATE ON db_owner.degree_requirement
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_degree_requirement_tech_col();

ALTER SEQUENCE db_owner.seq_degree_requirement_code
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_degree_requirement_code
TO db_owner;

\echo '=======================================';
\echo ' 37. CREATE LANGUAGE_REQUIREMENT TABLE ';
\echo '=======================================';

CREATE TABLE db_owner.language_requirement (
    language_requirement_id  BIGINT PRIMARY KEY,
    priority                 INTEGER NOT NULL,
    importance               VARCHAR(20) NOT NULL,
    nivel                    VARCHAR(30) NOT NULL,
    certification_required   CHAR(1) NOT NULL,
    description              VARCHAR(100),

    job_id                   BIGINT NOT NULL,
    lang_code                BIGINT NOT NULL,
    lang_level_id            BIGINT NOT NULL,

    creation_date            TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by               VARCHAR(50) NOT NULL,
    last_update_date         TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by          VARCHAR(50) NOT NULL,

    source_system            VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status              VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version             BIGINT DEFAULT 1 NOT NULL,
    last_synced_at           TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag             CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_lang_req_job FOREIGN KEY (job_id)
        REFERENCES db_owner.job(job_id),

    CONSTRAINT fk_lang_req_lang FOREIGN KEY (lang_code)
        REFERENCES db_owner.language(lang_code),

    CONSTRAINT fk_lang_req_level FOREIGN KEY (lang_level_id)
        REFERENCES db_owner.lang_level(lang_level_id)
);

ALTER TABLE db_owner.language_requirement OWNER TO db_owner;

COMMENT ON TABLE db_owner.language_requirement IS
'Links between job postings and required languages & language levels.';

COMMENT ON COLUMN db_owner.language_requirement.language_requirement_id IS 'The id of the language requirement';
COMMENT ON COLUMN db_owner.language_requirement.priority IS 'The priority of the language requirement';
COMMENT ON COLUMN db_owner.language_requirement.importance IS 'The importance of the language requirement';
COMMENT ON COLUMN db_owner.language_requirement.nivel IS 'The required proficiency level';
COMMENT ON COLUMN db_owner.language_requirement.certification_required IS 'Flag indicating if certification is required';
COMMENT ON COLUMN db_owner.language_requirement.description IS 'Description of the language requirement';

COMMENT ON COLUMN db_owner.language_requirement.job_id IS 'The job id';
COMMENT ON COLUMN db_owner.language_requirement.lang_code IS 'The language code';
COMMENT ON COLUMN db_owner.language_requirement.lang_level_id IS 'The language level id';

COMMENT ON COLUMN db_owner.language_requirement.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.language_requirement.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.language_requirement.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.language_requirement.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.language_requirement.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.language_requirement.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.language_requirement.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.language_requirement.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.language_requirement.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_language_requirement_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_language_requirement_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.language_requirement_id IS NULL THEN
        NEW.language_requirement_id := nextval('db_owner.seq_language_requirement_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_language_requirement_id_pk
BEFORE INSERT ON db_owner.language_requirement
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_language_requirement_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_language_requirement_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_language_requirement_tech_col
BEFORE INSERT OR UPDATE ON db_owner.language_requirement
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_language_requirement_tech_col();

ALTER SEQUENCE db_owner.seq_language_requirement_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_language_requirement_id
TO db_owner;

\echo '============================';
\echo ' 38. CREATE JOB_SKILL TABLE ';
\echo '============================';

CREATE TABLE db_owner.job_skill (
    skill_code              BIGINT NOT NULL,
    job_id                  BIGINT NOT NULL,
    required_level          NUMERIC(5,2) NOT NULL,
    importance_weight       NUMERIC(5,2) NOT NULL,
    is_mandatory            CHAR(1) NOT NULL,
    min_experience_months   INTEGER NOT NULL,
    max_months_since_used   INTEGER,
    description             VARCHAR(500),

    creation_date           TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by              VARCHAR(50) NOT NULL,
    last_update_date        TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by         VARCHAR(50) NOT NULL,

    source_system           VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status             VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version            BIGINT DEFAULT 1 NOT NULL,
    last_synced_at          TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag            CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT pk_job_skill PRIMARY KEY (skill_code, job_id),

    CONSTRAINT fk_job_skill_job FOREIGN KEY (job_id)
        REFERENCES db_owner.job(job_id),

    CONSTRAINT fk_job_skill_skill FOREIGN KEY (skill_code)
        REFERENCES db_owner.skill(skill_code)
);

ALTER TABLE db_owner.job_skill OWNER TO db_owner;

COMMENT ON TABLE db_owner.job_skill IS
'Links between job postings and required skills.';

COMMENT ON COLUMN db_owner.job_skill.skill_code IS 'The skill code';
COMMENT ON COLUMN db_owner.job_skill.job_id IS 'The job id';
COMMENT ON COLUMN db_owner.job_skill.required_level IS 'Required proficiency level';
COMMENT ON COLUMN db_owner.job_skill.importance_weight IS 'Importance weight of the skill';
COMMENT ON COLUMN db_owner.job_skill.is_mandatory IS 'Flag indicating if the skill is mandatory';
COMMENT ON COLUMN db_owner.job_skill.min_experience_months IS 'Minimum required experience in months';
COMMENT ON COLUMN db_owner.job_skill.max_months_since_used IS 'Maximum allowed months since last used';
COMMENT ON COLUMN db_owner.job_skill.description IS 'Description of the skill requirement';

COMMENT ON COLUMN db_owner.job_skill.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.job_skill.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.job_skill.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.job_skill.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.job_skill.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.job_skill.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.job_skill.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.job_skill.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.job_skill.deleted_flag IS 'Technical Column - soft delete flag';

CREATE OR REPLACE FUNCTION db_owner.fn_job_skill_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;

        IF NEW.creation_date IS NULL THEN
            NEW.creation_date := NOW();
        END IF;

        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NEW.creation_date;
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_skill_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job_skill
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_skill_tech_col();

\echo '==================================';
\echo ' 39. CREATE JOB_APPLICATION TABLE ';
\echo '==================================';

CREATE TABLE db_owner.job_application (
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
    deleted_flag        CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_job_application_user FOREIGN KEY (user_id)
        REFERENCES db_owner.utilizatori(user_id),

    CONSTRAINT fk_job_application_job FOREIGN KEY (job_id)
        REFERENCES db_owner.job(job_id)
);

ALTER TABLE db_owner.job_application OWNER TO db_owner;

COMMENT ON TABLE db_owner.job_application IS
'Applications submitted by users for job postings.';

COMMENT ON COLUMN db_owner.job_application.application_id IS 'The id of the application';
COMMENT ON COLUMN db_owner.job_application.apply_date IS 'The date when the user applied';
COMMENT ON COLUMN db_owner.job_application.apply_source IS 'The source of the application';
COMMENT ON COLUMN db_owner.job_application.status IS 'The status of the application';
COMMENT ON COLUMN db_owner.job_application.salary IS 'The salary associated with the application';

COMMENT ON COLUMN db_owner.job_application.user_id IS 'The id of the user';
COMMENT ON COLUMN db_owner.job_application.job_id IS 'The id of the job';

COMMENT ON COLUMN db_owner.job_application.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.job_application.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.job_application.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.job_application.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.job_application.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.job_application.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.job_application.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.job_application.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.job_application.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_application_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_application_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.application_id IS NULL THEN
        NEW.application_id := nextval('db_owner.seq_application_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_application_id_pk
BEFORE INSERT ON db_owner.job_application
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_application_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_job_application_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_application_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job_application
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_application_tech_col();

ALTER SEQUENCE db_owner.seq_application_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_application_id
TO db_owner;

\echo '==============================';
\echo ' 40. CREATE JOB_HISTORY TABLE ';
\echo '==============================';

CREATE TABLE db_owner.job_history (
    job_history_id     BIGINT PRIMARY KEY,
    start_date         DATE NOT NULL,
    end_date           DATE NOT NULL,
    salary             BIGINT NOT NULL,

    user_id            BIGINT NOT NULL,
    job_id             BIGINT NOT NULL,
    application_id     BIGINT NOT NULL,

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_job_history_user FOREIGN KEY (user_id)
        REFERENCES db_owner.utilizatori(user_id),

    CONSTRAINT fk_job_history_job FOREIGN KEY (job_id)
        REFERENCES db_owner.job(job_id),

    CONSTRAINT fk_job_history_application FOREIGN KEY (application_id)
        REFERENCES db_owner.job_application(application_id)
);

ALTER TABLE db_owner.job_history OWNER TO db_owner;

COMMENT ON TABLE db_owner.job_history IS
'History of job engagements for users who applied and were hired.';

COMMENT ON COLUMN db_owner.job_history.job_history_id IS 'The id of the job history record';
COMMENT ON COLUMN db_owner.job_history.start_date IS 'The start date of the job';
COMMENT ON COLUMN db_owner.job_history.end_date IS 'The end date of the job';
COMMENT ON COLUMN db_owner.job_history.salary IS 'The salary for the job';

COMMENT ON COLUMN db_owner.job_history.user_id IS 'The id of the user';
COMMENT ON COLUMN db_owner.job_history.job_id IS 'The id of the job';
COMMENT ON COLUMN db_owner.job_history.application_id IS 'The id of the job application';

COMMENT ON COLUMN db_owner.job_history.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.job_history.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.job_history.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.job_history.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.job_history.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.job_history.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.job_history.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.job_history.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.job_history.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_job_history_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_job_history_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.job_history_id IS NULL THEN
        NEW.job_history_id := nextval('db_owner.seq_job_history_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_history_id_pk
BEFORE INSERT ON db_owner.job_history
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_history_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_job_history_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_job_history_tech_col
BEFORE INSERT OR UPDATE ON db_owner.job_history
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_job_history_tech_col();

ALTER SEQUENCE db_owner.seq_job_history_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_job_history_id
TO db_owner;

\echo '=========================';
\echo ' 41. CREATE REVIEW TABLE ';
\echo '=========================';

CREATE TABLE db_owner.review (
    review_id          BIGINT PRIMARY KEY,
    title              VARCHAR(100) NOT NULL,
    review_type        VARCHAR(30) NOT NULL,
    description        VARCHAR(500) NOT NULL,

    rating_overall NUMERIC(5,2) GENERATED ALWAYS AS (
        ROUND(
            (
                COALESCE(work_rating,0)
              + COALESCE(salary_rating,0)
              + COALESCE(manager_rating,0)
              + COALESCE(team_rating,0)
            )
            /
            NULLIF(
                (CASE WHEN work_rating IS NOT NULL THEN 1 ELSE 0 END) +
                (CASE WHEN salary_rating IS NOT NULL THEN 1 ELSE 0 END) +
                (CASE WHEN manager_rating IS NOT NULL THEN 1 ELSE 0 END) +
                (CASE WHEN team_rating IS NOT NULL THEN 1 ELSE 0 END),
            0)
        ,2)
    ) STORED,

    work_rating        NUMERIC(5,2) NOT NULL,
    salary_rating      NUMERIC(5,2) NOT NULL,
    manager_rating     NUMERIC(5,2) NOT NULL,
    team_rating        NUMERIC(5,2) NOT NULL,

    would_recommend    CHAR(1) NOT NULL,
    is_anonymous       CHAR(1) NOT NULL,
    is_verified        CHAR(1) NOT NULL,

    job_id             BIGINT NOT NULL,
    user_id            BIGINT NOT NULL,
    job_history_id     BIGINT NOT NULL,
    application_id     BIGINT NOT NULL,

    creation_date      TIMESTAMP DEFAULT NOW() NOT NULL,
    created_by         VARCHAR(50) NOT NULL,
    last_update_date   TIMESTAMP DEFAULT NOW() NOT NULL,
    last_updated_by    VARCHAR(50) NOT NULL,

    source_system      VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
    sync_status        VARCHAR(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
    sync_version       BIGINT DEFAULT 1 NOT NULL,
    last_synced_at     TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_flag       CHAR(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

    CONSTRAINT fk_review_job FOREIGN KEY (job_id)
        REFERENCES db_owner.job(job_id),

    CONSTRAINT fk_review_user FOREIGN KEY (user_id)
        REFERENCES db_owner.utilizatori(user_id),

    CONSTRAINT fk_review_job_history FOREIGN KEY (job_history_id)
        REFERENCES db_owner.job_history(job_history_id),

    CONSTRAINT fk_review_application FOREIGN KEY (application_id)
        REFERENCES db_owner.job_application(application_id)
);

ALTER TABLE db_owner.review OWNER TO db_owner;

COMMENT ON TABLE db_owner.review IS
'Reviews submitted by users after completing a job engagement.';

COMMENT ON COLUMN db_owner.review.review_id IS 'The id of the review';
COMMENT ON COLUMN db_owner.review.title IS 'The title of the review';
COMMENT ON COLUMN db_owner.review.review_type IS 'The type of the review';
COMMENT ON COLUMN db_owner.review.description IS 'The description of the review';

COMMENT ON COLUMN db_owner.review.rating_overall IS 'The computed overall rating';
COMMENT ON COLUMN db_owner.review.work_rating IS 'Work environment rating';
COMMENT ON COLUMN db_owner.review.salary_rating IS 'Salary rating';
COMMENT ON COLUMN db_owner.review.manager_rating IS 'Manager rating';
COMMENT ON COLUMN db_owner.review.team_rating IS 'Team rating';

COMMENT ON COLUMN db_owner.review.would_recommend IS 'Flag indicating if the user recommends the job';
COMMENT ON COLUMN db_owner.review.is_anonymous IS 'Flag indicating if the review is anonymous';
COMMENT ON COLUMN db_owner.review.is_verified IS 'Flag indicating if the review is verified';

COMMENT ON COLUMN db_owner.review.job_id IS 'The job id';
COMMENT ON COLUMN db_owner.review.user_id IS 'The user id';
COMMENT ON COLUMN db_owner.review.job_history_id IS 'The job history id';
COMMENT ON COLUMN db_owner.review.application_id IS 'The application id';

COMMENT ON COLUMN db_owner.review.creation_date IS 'Technical Column - creation timestamp';
COMMENT ON COLUMN db_owner.review.created_by IS 'Technical Column - creator user';
COMMENT ON COLUMN db_owner.review.last_update_date IS 'Technical Column - last update timestamp';
COMMENT ON COLUMN db_owner.review.last_updated_by IS 'Technical Column - last updater user';
COMMENT ON COLUMN db_owner.review.source_system IS 'Technical Column - source system';
COMMENT ON COLUMN db_owner.review.sync_status IS 'Technical Column - sync status';
COMMENT ON COLUMN db_owner.review.sync_version IS 'Technical Column - sync version';
COMMENT ON COLUMN db_owner.review.last_synced_at IS 'Technical Column - last sync timestamp';
COMMENT ON COLUMN db_owner.review.deleted_flag IS 'Technical Column - soft delete flag';

CREATE SEQUENCE db_owner.seq_review_id
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

CREATE OR REPLACE FUNCTION db_owner.fn_review_id_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.review_id IS NULL THEN
        NEW.review_id := nextval('db_owner.seq_review_id');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_id_pk
BEFORE INSERT ON db_owner.review
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_review_id_pk();

CREATE OR REPLACE FUNCTION db_owner.fn_review_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := CURRENT_USER;
        NEW.creation_date := NOW();
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    ELSE
        NEW.last_updated_by := CURRENT_USER;
        NEW.last_update_date := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_tech_col
BEFORE INSERT OR UPDATE ON db_owner.review
FOR EACH ROW EXECUTE FUNCTION db_owner.fn_review_tech_col();

ALTER SEQUENCE db_owner.seq_review_id
OWNER TO db_owner;

GRANT USAGE, SELECT, UPDATE
ON SEQUENCE db_owner.seq_review_id
TO db_owner;

\echo '=== END INIT SCRIPT 03_pg_db_owner.sql ==='