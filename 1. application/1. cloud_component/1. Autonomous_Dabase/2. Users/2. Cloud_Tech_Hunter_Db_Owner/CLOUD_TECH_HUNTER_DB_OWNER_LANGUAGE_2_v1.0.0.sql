--CLOUD_TECH_HUNTER_DB_OWNER_LANGUAGE_2_v1.0.0
--"LANGUAGE TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--DELETE TABLE LANGUAGE IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'LANGUAGE'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE tech_hunter_db_owner.language CASCADE CONSTRAINTS';
END IF;
--CREATE LANGUAGE TABLE;
v_sql := q'[
        CREATE TABLE tech_hunter_db_owner.language (
          lang_code             NUMBER(38,0) PRIMARY KEY,
          name                  VARCHAR2(60) NOT NULL,
          iso_code              VARCHAR2(5) NOT NULL,
          no_native_speakers    NUMBER(20,0) NOT NULL,
          no_speakers           NUMBER(38,0) NOT NULL,
          no_countries          NUMBER(5,0) NOT NULL,
          rating                NUMBER(5,2) GENERATED ALWAYS AS (
                                  ROUND((
                                    0.4 * LOG(10, no_native_speakers + 1) +
                                    0.5 * LOG(10, no_speakers + 1) +
                                    0.1 * SQRT(no_countries)
                                  ) / 9.2 * 100, 2)
                                ) VIRTUAL,
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'LANGUAGE'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The LANGUAGE table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The LANGUAGE table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE tech_hunter_db_owner.language IS ''The table contains the spoken languages of students''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.lang_code IS ''The primary key of the language table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.name IS ''The name of the language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.iso_code IS ''The ISO code of the language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.no_native_speakers IS ''The number of native speakers''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.no_speakers IS ''The number of speakers''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.no_countries IS ''The number of countries where you can speak this language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.rating IS ''The rating of this language, calculated based on speakers and country spread''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.language.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_LANGUAGE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
EXECUTE IMMEDIATE 'DROP SEQUENCE seq_language_id';
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_language_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';

--CREATE TRIGGER FOR PRIMARY KEY
v_sql := 'CREATE OR REPLACE TRIGGER trg_language_id
          BEFORE INSERT ON tech_hunter_db_owner.language
          FOR EACH ROW
          WHEN (NEW.lang_code IS NULL)
          BEGIN
             SELECT seq_language_id.NEXTVAL INTO :NEW.lang_code FROM dual;
          END;';
EXECUTE IMMEDIATE v_sql;

--CREATE TRIGGER FOR TECHNICAL COLUMNS
v_sql := '  CREATE OR REPLACE TRIGGER trg_language_technical_columns
            BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.language
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


DBMS_OUTPUT.PUT_LINE('[3.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;

/

