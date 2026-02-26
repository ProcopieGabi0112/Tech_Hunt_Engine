--AUTONOMOUS_DB_OWNER_TBL_TECHNOLOGY_1_v1.0.0
--"TECHNOLOGY TABLE"
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

--DELETE TABLE TECHNOLOGY IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'TECHNOLOGY'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.technology CASCADE CONSTRAINTS';
END IF;
--CREATE TECHNOLOGY TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.technology (
          --business columns
          technology_code	NUMBER(38,0),
          name	            VARCHAR2(100),
          release_date	    DATE,
          creator	        VARCHAR2(100),
          official_site	    VARCHAR2(255),
          rating	NUMBER(5,2) DEFAULT 0 NOT NULL,
          description	VARCHAR2(250),
          sign_photo	BLOB,
          technology_type_code	NUMBER(38,0) NOT NULL,

          --technical columns
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),
          CONSTRAINT fk_technology_type_code FOREIGN KEY (technology_type_code) REFERENCES technology_type (technology_type_code)
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'TECHNOLOGY'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECHNOLOGY table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The TECHNOLOGY table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.technology IS ''This table will contains the technologies name like Postgress Database, Spring Boot, React Native, etc''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.technology_code IS ''The code of the technology type''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.technology_code IS ''The code of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.name IS ''The name of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.release_date IS ''The release date of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.creator IS ''The creator of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.official_site IS ''The official site of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.rating IS ''The rating of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.description IS ''The description of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.sign_photo IS ''The sign photo of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.technology_type_code IS ''The code of the technology type''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.technology.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_technology_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_TECHNOLOGY_CODE';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.seq_technology_code';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_technology_code
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_TECHNOLOGY_CODE';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_TECHNOLOGY_CODE sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_TECHNOLOGY_CODE sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_CODE_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_technology_code_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_technology_code_pk
          BEFORE INSERT ON autonomous_db_owner.technology
          FOR EACH ROW
          WHEN (NEW.technology_code IS NULL)
          BEGIN
             SELECT seq_technology_code.NEXTVAL INTO :NEW.technology_code FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_CODE_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_TECHNOLOGY_CODE_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_TECHNOLOGY_CODE_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_technology_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_technology_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.technology
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
WHERE trigger_name = 'TRG_TECHNOLOGY_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_TECHNOLOGY_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_TECHNOLOGY_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR POPULATING THE rating column FROM TECHNOLOGY_TYPE TABLE
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_TYPE_RATING_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_technology_type_rating_sync';
END IF;
--CREATE TRIGGER
v_sql := '  
        CREATE OR REPLACE TRIGGER trg_technology_type_rating_sync
        AFTER INSERT OR UPDATE OR DELETE ON autonomous_db_owner.technology
        DECLARE
            v_type_code NUMBER;
        BEGIN
            -- Determine affected technology_type_code
            IF INSERTING THEN
                v_type_code := :NEW.technology_type_code;

            ELSIF UPDATING THEN
                -- If type changed, recalc for old type
                IF :OLD.technology_type_code != :NEW.technology_type_code THEN
                    UPDATE autonomous_db_owner.technology_type tt
                       SET tt.rating = (
                           SELECT AVG(t.rating)
                             FROM autonomous_db_owner.technology t
                            WHERE t.technology_type_code = :OLD.technology_type_code
                       )
                     WHERE tt.technology_type_code = :OLD.technology_type_code;
                END IF;

                v_type_code := :NEW.technology_type_code;

            ELSIF DELETING THEN
                v_type_code := :OLD.technology_type_code;
            END IF;

            -- Recalculate rating for current type
            UPDATE autonomous_db_owner.technology_type tt
               SET tt.rating = (
                   SELECT AVG(t.rating)
                     FROM autonomous_db_owner.technology t
                    WHERE t.technology_type_code = v_type_code
               )
             WHERE tt.technology_type_code = v_type_code;
        END;
    ';
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_TYPE_RATING_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_TECHNOLOGY_TYPE_RATING_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_TECHNOLOGY_TYPE_RATING_SYNC trigger for populating the rating column from technology_type table.');

DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/