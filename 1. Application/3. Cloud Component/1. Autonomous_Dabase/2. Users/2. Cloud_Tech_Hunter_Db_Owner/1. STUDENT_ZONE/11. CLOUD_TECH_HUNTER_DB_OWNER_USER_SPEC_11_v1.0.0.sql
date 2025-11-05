--CLOUD_TECH_HUNTER_DB_OWNER_USER_SPEC_10_v1.0.0
--"USER_SPEC TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');
--DELETE TABLE USER_SPEC IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'USER_SPEC'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE tech_hunter_db_owner.user_spec CASCADE CONSTRAINTS';
END IF;
--CREATE USER_SPEC TABLE;
v_sql := q'[
        CREATE TABLE tech_hunter_db_owner.user_spec (
		  email                 VARCHAR2(70) NOT NULL,
          specialization_id     NUMBER(38,0) NOT NULL,

          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL CHECK (source_system IN ('cloud_env','postgress_env','mongo_env')),
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),
          PRIMARY KEY (email, specialization_id),
          FOREIGN KEY (email) REFERENCES utilizatori(email),
          FOREIGN KEY (specialization_id) REFERENCES specialization(specialization_id)
)
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'USER_SPEC'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The USER_SPEC table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The USER_SPEC table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  tech_hunter_db_owner.user_spec IS ''The associative table between users and specialization tables.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.email IS ''The primary key from utilizatori table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.specialization_id IS ''The primary key from specialization table''';
-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.user_spec.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_USER_SPEC_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_user_spec_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_user_spec_tech_col
            BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.user_spec
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
                    :NEW.created_by := USER;
                    :NEW.last_updated_by := USER;
                    :NEW.creation_date := CURRENT_TIMESTAMP;
                    :NEW.last_update_date := CURRENT_TIMESTAMP;
                 END IF;

                 IF UPDATING THEN
                    :NEW.last_update_date := CURRENT_TIMESTAMP;
                    :NEW.last_updated_by := USER;
                 END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_USER_SPEC_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_USER_SPEC_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The TRG_USER_SPEC_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR RATING UPDATE ON INSTITUTION
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_UPDATE_INSTITUTION_RATING';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_update_institution_rating';
END IF;

--CREATE TRIGGER
v_sql := q'[
    CREATE OR REPLACE TRIGGER trg_update_institution_rating
    AFTER INSERT OR UPDATE OR DELETE ON tech_hunter_db_owner.specialization
    DECLARE
    BEGIN
        FOR rec IN (
            SELECT institution_id,
                   ROUND(AVG(rating), 2) AS computed_rating
            FROM tech_hunter_db_owner.specialization
            GROUP BY institution_id
        ) LOOP
            UPDATE tech_hunter_db_owner.institution
            SET rating = rec.computed_rating
            WHERE institution_id = rec.institution_id;
        END LOOP;
    END;
]';
EXECUTE IMMEDIATE v_sql;

--CHECK IF THE TRIGGER WAS CREATED
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_UPDATE_INSTITUTION_RATING';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20003,'The TRG_UPDATE_INSTITUTION_RATING trigger wasn''t created properly.');
END IF;

DBMS_OUTPUT.PUT_LINE('[4.] The TRG_UPDATE_INSTITUTION_RATING trigger for institution rating update was created.');

DBMS_OUTPUT.PUT_LINE('[5.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;

/
