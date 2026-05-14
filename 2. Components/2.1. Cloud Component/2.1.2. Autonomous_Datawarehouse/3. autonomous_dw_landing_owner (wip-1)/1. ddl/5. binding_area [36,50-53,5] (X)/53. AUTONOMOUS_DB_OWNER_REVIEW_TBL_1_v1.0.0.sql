--AUTONOMOUS_DW_LANDING_OWNER_DWH_REVIEW_TBL_1_v1.0.0
--"DWH_REVIEW TABLE"
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

--DELETE TABLE DWH_REVIEW IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_REVIEW'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_landing_owner.dw_review CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_REVIEW TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_landing_owner.dw_review (

          --business columns
          review_id NUMBER(38,0),
          title VARCHAR2(100) NOT NULL,
          review_type VARCHAR2(30) NOT NULL,
          description VARCHAR2(500) NOT NULL,
          rating_overall NUMBER(5,2) GENERATED ALWAYS AS (
    CASE 
        WHEN 
            (CASE WHEN work_rating IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN salary_rating IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN manager_rating IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN team_rating IS NOT NULL THEN 1 ELSE 0 END) = 0
        THEN NULL
        ELSE ROUND(
                (NVL(work_rating,0) +
                 NVL(salary_rating,0) +
                 NVL(manager_rating,0) +
                 NVL(team_rating,0)) /
                (CASE WHEN work_rating IS NOT NULL THEN 1 ELSE 0 END +
                 CASE WHEN salary_rating IS NOT NULL THEN 1 ELSE 0 END +
                 CASE WHEN manager_rating IS NOT NULL THEN 1 ELSE 0 END +
                 CASE WHEN team_rating IS NOT NULL THEN 1 ELSE 0 END)
            , 2)
    END
) VIRTUAL,
          work_rating NUMBER(5,2) NOT NULL, 
          salary_rating NUMBER(5,2) NOT NULL,
          manager_rating NUMBER(5,2) NOT NULL,
          team_rating NUMBER(5,2) NOT NULL,
          would_recommend VARCHAR2(1) NOT NULL,
          is_anonymous VARCHAR2(1) NOT NULL,
          is_verified VARCHAR2(1) NOT NULL,
          job_id NUMBER(38,0) NOT NULL,
          user_id NUMBER(38,0) NOT NULL,
          job_history_id NUMBER(38,0),
          application_id NUMBER(38,0) NOT NULL,
          
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
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_landing_owner.dw_review TO autonomous_dw_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_REVIEW'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_REVIEW table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The DWH_REVIEW table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_landing_owner.dw_review IS ''The table contains all the reviews that come from a student that work on a job''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.review_id IS ''The id of the review''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.title IS ''The title of the review''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.review_type IS ''The type of the review''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.description IS ''The description of the review''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.rating_overall IS ''The overall rating of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.salary_rating IS ''The salary rating of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.manager_rating IS ''The manager rating of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.team_rating IS ''The team rating of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.would_recommend IS ''The flag that indicates if the user is anonymous or not''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.is_verified IS ''The flag that indicates if the review is verified''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.user_id IS ''The id of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.job_id IS ''The id of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.job_history_id IS ''The id of the job history''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.application_id IS ''The id of the application''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_review.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/