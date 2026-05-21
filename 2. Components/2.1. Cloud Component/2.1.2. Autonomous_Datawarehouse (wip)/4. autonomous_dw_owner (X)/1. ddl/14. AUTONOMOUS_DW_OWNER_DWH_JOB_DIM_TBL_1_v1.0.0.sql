--AUTONOMOUS_DW_OWNER_DWH_JOB_DIM_TBL_1_v1.0.0
--"DWH_JOB_DIM TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--[1.] CHECK CURRENT JOB AND SCHEMA
SELECT COUNT(*) INTO v_count
FROM dual
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DW_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE specialization_type IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_JOB_DIM'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_owner.dwh_job_dim CASCADE CONSTRAINTS';
END IF;


--CREATE UTILIZATORI TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_owner.dwh_job_dim (

          --business columns
          job_key NUMBER(38,0) PRIMARY KEY,
          job_id NUMBER(38,0) NOT NULL,
          publish_date DATE NOT NULL,
          hire_date DATE NOT NULL,
          expiry_date DATE,
          employment_period NUMBER(10,0),
          salary_min NUMBER(15,0) NOT NULL,
          salary_max NUMBER(15,0) NOT NULL,
          currency_code NUMBER(38,0) NOT NULL,
          currency_name VARCHAR2(200) NOT NULL,
          demand_score NUMBER(5,2) NOT NULL,
          complexity_score NUMBER(5,2) NOT NULL,
          job_status VARCHAR2(50) NOT NULL,
          language_requirement VARCHAR2(4000) NOT NULL,
          certifications_score NUMBER(5,2) NOT NULL,
          degree_requirement VARCHAR2(4000) NOT NULL,
          academic_score NUMBER(5,2) NOT NULL,
          employment_type_id NUMBER(5,2) NOT NULL,
          employment_type_name VARCHAR2(50) NOT NULL,
          employment_type_score NUMBER(5,2) NOT NULL,
          work_type_id NUMBER(10,0) NOT NULL,
          work_type_name VARCHAR2(50) NOT NULL,
          work_type_score NUMBER(5,2) NOT NULL,
          job_category_id NUMBER(25,0) NOT NULL,
          job_category_name VARCHAR2(100) NOT NULL,
          job_category_score NUMBER(5,2) NOT NULL,
          job_title_id NUMBER(25,0) NOT NULL,
          job_title_name VARCHAR2(100) NOT NULL,
          job_title_score NUMBER(5,2) NOT NULL,
          job_level_id NUMBER(10,0) NOT NULL,
          job_level_name VARCHAR2(50) NOT NULL,
          job_level_score NUMBER(5,2) NOT NULL,
          department_id NUMBER(38,0) NOT NULL,
          department_type_name VARCHAR2(100) NOT NULL,
          department_rating NUMBER(5,2) NOT NULL,
          company_key NUMBER(38,0) NOT NULL,
          job_location_key NUMBER(38,0) NOT NULL,
          
          --technical columns
          creation_date         TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          valid_from            TIMESTAMP NOT NULL,
          valid_to              TIMESTAMP NOT NULL,
          source_system         VARCHAR2(20) NOT NULL CHECK (source_system IN ('db_env')),
          deleted_flag          VARCHAR2(1) NOT NULL CHECK (deleted_flag IN ('N','Y')),
          CONSTRAINT fk_job_dim_location FOREIGN KEY (job_location_key) REFERENCES autonomous_dw_owner.dwh_job_location_dim (job_location_key),
          CONSTRAINT fk_company_dim FOREIGN KEY (company_key) REFERENCES autonomous_dw_owner.dwh_company_dim (company_key)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_owner.dwh_job_dim TO autonomous_dw_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_JOB_DIM'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_JOB_DIM table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_JOB_DIM table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_owner.dwh_job_dim IS ''Dimension table containing enriched job information with financial, organizational and ML-ready metrics.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_key IS ''Surrogate key of the job dimension.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_id IS ''Natural key of the job from the source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.publish_date IS ''Date when the job was published.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.hire_date IS ''Date when the job becomes active for recruitment.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.expiry_date IS ''Date when the job posting expires.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.employment_period IS ''Number of days between publish_date and expiry_date.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.salary_min IS ''Minimum salary offered for the job.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.salary_max IS ''Maximum salary offered for the job.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.currency_code IS ''Numeric code of the salary currency.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.currency_name IS ''Name of the salary currency (e.g., EUR, USD).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.demand_score IS ''Score representing the demand level for this job.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.complexity_score IS ''Global complexity score computed in the source system using skills, languages, certifications and academic requirements.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_status IS ''Current status of the job (e.g., ACTIVE, CLOSED).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.language_requirement IS ''JSON structure describing language requirements, levels, importance and ratings.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.certifications_score IS ''Aggregated numeric score derived from language and certification requirements.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.degree_requirement IS ''JSON structure describing academic requirements, degree types, importance and institution details.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.academic_score IS ''Aggregated numeric score derived from academic requirements and institution ratings.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.employment_type_id IS ''Identifier of the employment type (e.g., full-time, part-time).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.employment_type_name IS ''Name of the employment type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.employment_type_score IS ''Complexity or relevance score associated with the employment type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.work_type_id IS ''Identifier of the work type (e.g., remote, onsite).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.work_type_name IS ''Name of the work type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.work_type_score IS ''Complexity or relevance score associated with the work type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_category_id IS ''Identifier of the job category.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_category_name IS ''Name of the job category.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_category_score IS ''Complexity or relevance score associated with the job category.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_title_id IS ''Identifier of the job title.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_title_name IS ''Name of the job title.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_title_score IS ''Complexity or relevance score associated with the job title.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_level_id IS ''Identifier of the job level (e.g., Junior, Senior).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_level_name IS ''Name of the job level.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_level_score IS ''Complexity or relevance score associated with the job level.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.department_id IS ''Identifier of the department associated with the job.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.department_type_name IS ''Type of the department (e.g., Technical, Administrative).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.department_rating IS ''Rating score associated with the department.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.company_key IS ''Foreign key referencing the company dimension.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.job_location_key IS ''Foreign key referencing the job location dimension.''';
-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.valid_from IS ''Technical Column - The timestamp indicating when the record becomes effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.valid_to IS ''Technical Column - The timestamp indicating when the record stops being effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_job_dim.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_TECHNOLOGY_TYPE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_JOB_KEY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_dw_owner.seq_job_key';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_job_key
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_JOB_KEY';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_JOB_KEY sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_JOB_KEY sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_JOB_KEY_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_job_key_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_job_key_pk
          BEFORE INSERT ON autonomous_dw_owner.dwh_job_dim
          FOR EACH ROW
          WHEN (NEW.job_key IS NULL)
          BEGIN
             SELECT seq_job_key.NEXTVAL INTO :NEW.job_key FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_JOB_KEY_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_JOB_KEY_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_JOB_KEY_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_JOB_DIM_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_job_dim_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_dwh_job_dim_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_job_dim
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
        -- creation metadata
        :NEW.creation_date := CURRENT_TIMESTAMP;
        :NEW.created_by := ''ETL_JOB_DAILY_PROCESS'';

        -- update metadata
        :NEW.last_update_date := :NEW.creation_date;
        :NEW.last_updated_by := ''ETL_JOB_DAILY_PROCESS'';

        -- validity (SCD1 → no history)
        :NEW.valid_from := CURRENT_TIMESTAMP;
        :NEW.valid_to := TO_TIMESTAMP(''9999-12-31 23:59:59'', ''YYYY-MM-DD HH24:MI:SS'');

        -- source system
        IF :NEW.source_system IS NULL THEN
            :NEW.source_system := ''db_env'';
        END IF;

        -- deleted flag
        IF :NEW.deleted_flag IS NULL THEN
            :NEW.deleted_flag := ''N'';
        END IF;
    END IF;

    IF UPDATING THEN
        -- update metadata
        :NEW.last_update_date := CURRENT_TIMESTAMP;
        :NEW.last_updated_by := ''ETL_JOB_DAILY_PROCESS'';

    END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_JOB_DIM_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_JOB_DIM_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_DWH_JOB_DIM_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/