--AUTONOMOUS_DB_OWNER_JOB_SKILL_TBL_1_v1.0.0
--"JOB_SKILL TABLE"
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

--DELETE TABLE JOB_SKILL IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'JOB_SKILL'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.job_skill CASCADE CONSTRAINTS';
END IF;
--CREATE JOB_SKILL TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.job_skill (

          --business columns
          skill_code NUMBER(38,0) NOT NULL,
          job_id NUMBER(38,0) NOT NULL,
          required_level NUMBER(5,2) NOT NULL,
          importance_weight NUMBER(5,2) NOT NULL,
          is_mandatory VARCHAR2(1) NOT NULL,
          min_experience_months NUMBER(4,0) NOT NULL,
          max_months_since_used NUMBER(4,0),
          description VARCHAR2(500),
          
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

          CONSTRAINT pk_job_skill_skill_code_job_id PRIMARY KEY (skill_code, job_id),
          CONSTRAINT fk_job_id FOREIGN KEY (job_id) REFERENCES job (job_id),
          CONSTRAINT fk_technology_skill_code FOREIGN KEY (skill_code) REFERENCES skill (skill_code)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_db_owner.job_skill TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'JOB_SKILL'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The JOB_SKILL table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The JOB_SKILL table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.job_skill IS ''The table contains all the links between a user and the skill that he knows''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.job_id IS ''The id of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.skill_code IS ''The code of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.required_level IS ''The required level of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.importance_weight IS ''The importance weight of technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.is_mandatory IS ''TThe flag indicating if the technology skill is mandatory or not''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.min_experience_months IS ''The minimun months experience in the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.min_experience_months IS ''The maximum number or months until the student used that technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.description IS ''The description of the technology skill requirement''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job_skill.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_JOB_SKILL_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_job_skill_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_job_skill_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.job_skill
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
                    :NEW.created_by := USER;
                    :NEW.last_updated_by := USER;

                    -- VARIANTA CURENTA
                    -- dacă utilizatorul NU trimite creation_date, îl setăm noi
                        IF :NEW.creation_date IS NULL THEN
                              :NEW.creation_date := CURRENT_TIMESTAMP;
                        END IF;

                    -- last_update_date = creation_date (mereu la insert)
                    :NEW.last_update_date := :NEW.creation_date;
                   
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
WHERE trigger_name = 'TRG_JOB_SKILL_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_JOB_SKILL_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_JOB_SKILL_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/