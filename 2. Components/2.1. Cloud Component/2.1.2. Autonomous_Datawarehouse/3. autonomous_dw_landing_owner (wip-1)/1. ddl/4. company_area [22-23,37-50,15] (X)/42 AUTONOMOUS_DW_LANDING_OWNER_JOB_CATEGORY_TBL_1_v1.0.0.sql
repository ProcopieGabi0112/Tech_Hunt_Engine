--AUTONOMOUS_DW_LANDING_OWNER_DWH_JOB_CATEGORY_TBL_1_v1.0.0
--"DWH_JOB_CATEGORY TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DW_LANDING_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_LANDING_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE dw_job_category IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_JOB_CATEGORY'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_landing_owner.dw_job_category CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_JOB_CATEGORY TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_landing_owner.dw_job_category (

          --business columns
          job_category_id NUMBER(25,0),
          name VARCHAR2(100) NOT NULL, 
          complexity_score NUMBER(5,2) NOT NULL,
          code VARCHAR2(50) NOT NULL, 
          description VARCHAR2(200), 
          
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
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_landing_owner.dw_job_category TO autonomous_dw_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_JOB_CATEGORY'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_JOB_CATEGORY table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The DWH_JOB_CATEGORY table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_landing_owner.dw_job_category IS ''The table contains all the job categories you can have on a job''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.job_category_id IS ''The id of the job category''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.name IS ''The name of the job category''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.complexity_score IS ''The complexity score of the job category''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.code IS ''The code of the job category''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.description IS ''The desciption of the job category''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_job_category.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/