--AUTONOMOUS_DW_LANDING_OWNER_DWH_LANGUAGE_REQUIREMENT_TBL_1_v1.0.0
--"DWH_LANGUAGE_REQUIREMENT TABLE"
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

--DELETE TABLE DWH_LANGUAGE_REQUIREMENT IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_LANGUAGE_REQUIREMENT'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_landing_owner.dw_language_requirement CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_LANGUAGE_REQUIREMENT TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_landing_owner.dw_language_requirement (

          --business columns
          language_requirement_id NUMBER(38,0),
          priority NUMBER(3,0) NOT NULL,
          importance VARCHAR2(20) DEFAULT 'REQUIRED' NOT NULL CHECK (importance IN ('REQUIRED','OPTIONAL','NICE TO HAVE')),
          nivel VARCHAR2(30) NOT NULL,
          certification_required VARCHAR2(1) NOT NULL,
          description VARCHAR2(100),
          job_id NUMBER(38,0) NOT NULL,
          lang_code NUMBER(38,0) NOT NULL,
          lang_level_id NUMBER(38,0) NOT NULL,

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
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_landing_owner.dw_language_requirement TO autonomous_dw_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_LANGUAGE_REQUIREMENT'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_LANGUAGE_REQUIREMENT table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_LANGUAGE_REQUIREMENT table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_landing_owner.dw_language_requirement IS ''The table contains all the links between a job and language and lang_level tables based on job requirements''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.language_requirement_id IS ''The code of the language requirement''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.priority IS ''The priority of the language requirement''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.importance IS ''The importance of the language requirement''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.nivel IS ''The nivel of the language requirement''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.certification_required IS ''The flag that indicating if the certification is required or not''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.description IS ''The description of the language requirement''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.job_id IS ''The id of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.lang_code IS ''The code of the language''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.lang_level_id IS ''The id of the language certification''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_language_requirement.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/