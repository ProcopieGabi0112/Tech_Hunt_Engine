--AUTONOMOUS_DB_OWNER_SPECIALIZATION_TBL_1_v1.0.0
--"SPECIALIZATION TABLE"
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

--DELETE TABLE specialization IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'SPECIALIZATION'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.specialization CASCADE CONSTRAINTS';
END IF;
--CREATE SPECIALIZATION;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.specialization (

          --business columns
          specialization_id NUMBER(38,0) PRIMARY KEY,
          name VARCHAR2(200) NOT NULL,
          degree_type VARCHAR2(50) NOT NULL, 
          employment_rate NUMBER(5,2) NOT NULL, 
          teachers_feedback NUMBER(5,2) NOT NULL,
          courses_feedback NUMBER(5,2) NOT NULL,
          entry_difficulty NUMBER(5,2) NOT NULL,
          graduation_difficulty NUMBER(5,2) NOT NULL,
          industry_reputation NUMBER(5,2) NOT NULL,
          rating NUMBER(5,2) DEFAULT 0 NOT NULL, 
          description VARCHAR2(200),
          institution_id NUMBER(5,2) NOT NULL,
          specialization_type_id NUMBER(5,2) NOT NULL,
          
          --technical columns
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),

          CONSTRAINT fk_specialization_institution_id FOREIGN KEY (institution_id) REFERENCES institution (institution_id),
          CONSTRAINT fk_specialization_type_id FOREIGN KEY (specialization_type_id) REFERENCES specialization_type (specialization_type_id)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_db_owner.specialization TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'SPECIALIZATION'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SPECIALIZATION table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SPECIALIZATION table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.specialization IS ''The table contains the specilizations of institutions where the students learned.''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.specialization_id IS ''The id of the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.name IS ''The name of the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.degree_type IS ''The type of degree obtained after graduation''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.description IS ''The description of the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.employment_rate IS ''The employment rate of the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.teachers_feedback IS ''The teachers feedback from the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.courses_feedback IS ''The courses feedback from the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.entry_difficulty IS ''The difficulty to enter on this specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.graduation_difficulty IS ''The difficulty to finish on this specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.industry_reputation IS ''The industry reputation of this specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.rating IS ''The rating of the specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.institution_id IS ''The id of the institution where you can learn that specialization''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.specialization_type_id IS ''The id of specialization type you can achieve form that specialization''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.specialization.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_SPECIALIZATION_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_SPECIALIZATION_ID';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.seq_specialization_id';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_specialization_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_SPECIALIZATION_ID';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_SPECIALIZATION_ID sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_SPECIALIZATION_ID sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_ID_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_specialization_id_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_specialization_id_pk
          BEFORE INSERT ON autonomous_db_owner.specialization
          FOR EACH ROW
          WHEN (NEW.specialization_id IS NULL)
          BEGIN
             SELECT seq_specialization_id.NEXTVAL INTO :NEW.specialization_id FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_ID_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_SPECIALIZATION_ID_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_SPECIALIZATION_ID_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_specialization_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_specialization_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.specialization
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
WHERE trigger_name = 'TRG_SPECIALIZATION_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_SPECIALIZATION_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_SPECIALIZATION_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR SPECIALIZATION RATING SYNC
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_RATING_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_specialization_rating_sync';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_specialization_rating_sync
BEFORE INSERT OR UPDATE ON autonomous_db_owner.specialization
FOR EACH ROW
DECLARE
    v_complexity_score specialization_type.complexity_score%TYPE;
BEGIN
    SELECT complexity_score
    INTO v_complexity_score
    FROM autonomous_db_owner.specialization_type
    WHERE specialization_type_id = :NEW.specialization_type_id;

    :NEW.rating := ROUND(
          0.25 * :NEW.industry_reputation
        + 0.20 * :NEW.employment_rate
        + 0.08 * (100.00 - :NEW.graduation_difficulty)
        + 0.10 * :NEW.courses_feedback
        + 0.05 * (100.00 - :NEW.entry_difficulty)
        + 0.07 * :NEW.teachers_feedback
        + 0.25 * (100.00 - v_complexity_score)
    , 2);
END;
';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_RATING_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_SPECIALIZATION_RATING_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_SPECIALIZATION_RATING_SYNC trigger for populating specialization rating column was created.');

--CREATE TRIGGER FOR INSTITUTION RATING SYNC
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_INSTITUTION_RATING_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_institution_rating_sync';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_institution_avg_rating
FOR INSERT OR UPDATE OR DELETE ON autonomous_db_owner.specialization
COMPOUND TRIGGER

    TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    g_ids t_ids;

AFTER EACH ROW IS
BEGIN
    IF INSERTING OR UPDATING THEN
        g_ids(g_ids.COUNT+1) := :NEW.institution_id;
    ELSIF DELETING THEN
        g_ids(g_ids.COUNT+1) := :OLD.institution_id;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
    FOR i IN 1 .. g_ids.COUNT LOOP
        UPDATE autonomous_db_owner.institution inst
        SET inst.rating = (
            SELECT ROUND(AVG(s.rating),2)
            FROM autonomous_db_owner.specialization s
            WHERE s.institution_id = g_ids(i)
              AND s.deleted_flag = 'N'
        )
        WHERE inst.institution_id = g_ids(i);
    END LOOP;
END AFTER STATEMENT;

END trg_institution_avg_rating;
';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_INSTITUTION_RATING_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_INSTITUTION_RATING_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[8.] The TRG_INSTITUTION_RATING_SYNC trigger for populating specialization rating column was created.');


DBMS_OUTPUT.PUT_LINE('[9.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/