--AUTONOMOUS_DB_OWNER_LANGUAGE_TBL_1_v1.0.0
--"LANGUAGE TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--[1.] CHECK CURRENT USER AND SCHEMA
SELECT COUNT(*) INTO v_count
FROM dual
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DB_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DB_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE technology_type IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'LANGUAGE'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.language CASCADE CONSTRAINTS';
END IF;
--CREATE TECHNOLOGY_TYPE TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.language (
          --business columns
          lang_code              NUMBER(38,0) PRIMARY KEY,
          name                   VARCHAR2(60) NOT NULL,
          iso_code               VARCHAR2(5) NOT NULL,
          no_native_speakers     NUMBER(20,0) NOT NULL,
          no_speakers            NUMBER(38,0) NOT NULL,
          no_countries           NUMBER(5,0) NOT NULL,
          no_companies           NUMBER(20,0) NOT NULL,
          rating NUMBER(5,2) GENERATED ALWAYS AS (
                                                   ROUND((
                                                           0.3 * SQRT(no_countries) +
                                                           0.4 * LOG(10, no_companies + 1) +
                                                           0.2 * LOG(10, no_native_speakers + 1) +
                                                           0.1 * LOG(10, (no_speakers - no_native_speakers) + 1)
                                                          ) / 9.4 * 100, 2) ) VIRTUAL,
          --technical columns
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y'))
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_db_owner.language TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'LANGUAGE'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The LANGUAGE table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The LANGUAGE table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.language IS ''The table contains the spoken languages of students''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.lang_code IS ''The primary key of the language table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.name IS ''The name of the language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.iso_code IS ''The ISO code of the language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.no_native_speakers IS ''The number of native speakers''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.no_speakers IS ''The number of speakers''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.no_companies IS ''The number of campanies that use this language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.no_countries IS ''The number of countries where you can speak this language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.rating IS ''The rating of this language, calculated based on speakers and country spread''';


EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.language.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_LANG_CODE FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_LANG_CODE';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.SEQ_LANG_CODE';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_lang_code
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_LANG_CODE';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_LANG_CODE sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_LANG_CODE sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_LANG_CODE_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_lang_code_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_lang_code_pk
          BEFORE INSERT ON autonomous_db_owner.language
          FOR EACH ROW
          WHEN (NEW.lang_code IS NULL)
          BEGIN
             SELECT seq_lang_code.NEXTVAL INTO :NEW.lang_code FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_LANG_CODE_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_LANG_CODE_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_LANG_CODE_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_LANGUAGE_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_language_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_language_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.language
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
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_LANGUAGE_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_LANGUAGE_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_LANGUAGE_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/