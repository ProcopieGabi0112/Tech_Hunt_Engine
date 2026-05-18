--AUTONOMOUS_DW_OWNER_DWH_USER_SKILL_DIM_JOB_1_v1.0.0
--"DWH_USER_SKILL_DIM JOB"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'ADMIN'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "ADMIN"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

-- CREATE IL PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_USER_SKILL_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_user_skill_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
             CREATE OR REPLACE PROCEDURE prc_etl_user_skill_initial_load
             AS
                v_count             NUMBER;
                v_notification_id   VARCHAR2(200);
                v_error             VARCHAR2(4000);
             BEGIN
    ------------------------------------------ 
    -- [1.] INSERT NOTIFICATION (IN_PROGRESS)
    ------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_USER_SKILL_INITIAL_LOAD_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'INITIAL LOAD',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
     RETURNING notification_id INTO v_notification_id;
     COMMIT;
    ------------------------------------ 
    -- [2.] VALIDATE SOURCE TABLES SYNC
    ------------------------------------
 
    SELECT COUNT(*) INTO v_count
    FROM dual
    WHERE EXISTS ( SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_skill 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_version 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_technology 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_technology_type 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_technology_dependency 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  );
                    
    IF v_count = 0 THEN
        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = 'Source tables not synced today'
        WHERE notification_id = v_notification_id;
        COMMIT;
        RETURN;
    END IF;

    ------------------------- 
    -- [4.] MERGE DIM TABLE
    -------------------------

    MERGE INTO autonomous_dw_owner.dwh_user_skill_dim d
    USING (
       SELECT DISTNCT 
    -- KEYS
    spec.specialization_id,
    spec.institution_id,
    spec.specialization_type_id,

    -- FEATURES BRUTE
    spec.rating AS specialization_rating,
    spec.employment_rate,
    spec.teachers_feedback,
    spec.courses_feedback,
    spec.entry_difficulty,
    spec.graduation_difficulty,
    spec.industry_reputation,
    st.complexity_score AS specialization_type_complexity,
    inst.rating AS institution_rating,
    inst.founding_year AS institution_founding_year,

    ----------------------------------------------------------------
    -- FEATURES DERIVATE (ML GOLD)
    ----------------------------------------------------------------

    -- 1. feedback_score
    (spec.teachers_feedback + spec.courses_feedback) / 2
        AS feedback_score,

    -- 2. difficulty_score
    (spec.entry_difficulty + spec.graduation_difficulty) / 2
        AS difficulty_score,

    -- 3. overall_score
    (
        spec.rating +
        spec.industry_reputation +
        spec.employment_rate +
        ((spec.teachers_feedback + spec.courses_feedback) / 2)
    ) / 4 AS overall_score,

    -- 4. institution_age
    EXTRACT(YEAR FROM CURRENT_DATE) - inst.founding_year
        AS institution_age,

    -- 5. institution_reputation_score
    (inst.rating + st.complexity_score) / 2
        AS institution_reputation_score,

    ----------------------------------------------------------------
    -- 6. specialization_category (optional)
    ----------------------------------------------------------------
    CASE
        WHEN st.code LIKE 'STEM%' THEN 'STEM'
        WHEN st.code LIKE 'BUS%'  THEN 'BUSINESS'
        WHEN st.code LIKE 'MED%'  THEN 'MEDICAL'
        ELSE 'OTHER'
    END AS specialization_category

FROM autonomous_dw_landing_owner.dwh_specialization spec
JOIN autonomous_dw_landing_owner.dwh_specialization_type st
    ON spec.specialization_type_id = st.specialization_type_id
JOIN autonomous_dw_landing_owner.dwh_institution inst
    ON spec.institution_id = inst.institution_id
WHERE spec.deleted_flag = 'N'
  AND st.deleted_flag = 'N'
  AND inst.deleted_flag = 'N';
           ) s
    ON (d.skill_code = s.skill_code)
    WHEN MATCHED THEN UPDATE SET

       d.skill_name                             = s.skill_name,
       d.prerequisite_knowledge_score           = s.prerequisite_knowledge_score,
       d.learning_difficulty_score              = s.learning_difficulty_score,
       d.implementation_difficulty_score        = s.implementation_difficulty_score,
       d.cross_platform_applicability_score     = s.cross_platform_applicability_score,
       d.skill_rating                           = s.skill_rating,
       d.version_code                           = s.version_code,
       d.version_name                           = s.version_name,
       d.version_release_date                   = s.version_release_date,
       d.version_end_of_life                    = s.version_end_of_life,
       d.developer_popularity_score             = s.developer_popularity_score,
       d.community_support_score                = s.community_support_score,
       d.industry_usage_score                   = s.industry_usage_score,
       d.knowledge_score                        = s.knowledge_score,
       d.version_skill_rating                   = s.version_skill_rating,
       d.version_rating                         = s.version_rating,
       d.technology_code                        = s.technology_code,
       d.technology_name                        = s.technology_name,
       d.technology_rating                      = s.technology_rating,
       d.technology_type_code                   = s.technology_type_code,
       d.technology_type_name                   = s.technology_type_name,
       d.technology_type_rating                 = s.technology_type_rating,
       d.deleted_flag                           = 'N',
       d.last_update_date                       = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

      skill_code,
      skill_name,
      prerequisite_knowledge_score,
      learning_difficulty_score,
      implementation_difficulty_score,
      cross_platform_applicability_score,
      skill_rating,
      version_code,
      version_name,
      version_release_date,
      version_end_of_life,
      developer_popularity_score,
      community_support_score,
      industry_usage_score,
      knowledge_score,
      version_skill_rating,
      version_rating,
      technology_code,
      technology_name,
      technology_rating,
      technology_type_code,
      technology_type_name,
      technology_type_rating,
      deleted_flag,
      creation_date,
      last_update_date
)
VALUES (
      s.skill_code,
      s.skill_name,
      s.prerequisite_knowledge_score,
      s.learning_difficulty_score,
      s.implementation_difficulty_score,
      s.cross_platform_applicability_score,
      s.skill_rating,
      s.version_code,
      s.version_name,
      s.version_release_date,
      s.version_end_of_life,
      s.developer_popularity_score,
      s.community_support_score,
      s.industry_usage_score,
      s.knowledge_score,
      s.version_skill_rating,
      s.version_rating,
      s.technology_code,
      s.technology_name,
      s.technology_rating,
      s.technology_type_code,
      s.technology_type_name,
      s.technology_type_rating,
      'N',
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
);
    COMMIT;

---------------------------------------------------------------------- 
-- [5.] SUCCESS NOTIFICATION
----------------------------------------------------------------------

    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'DONE',
        end_timestamp = CURRENT_TIMESTAMP
    WHERE notification_id = v_notification_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;

        v_error := SQLERRM;

        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = v_error
        WHERE notification_id = v_notification_id;

        COMMIT;

        RAISE_APPLICATION_ERROR(-20002, v_error);

END;
 ]';

 EXECUTE IMMEDIATE v_sql;

--[1.] VERIFY IF THE PROCEDURE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_USER_SKILL_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_USER_SKILL_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_USER_SKILL_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_user_skill_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_USER_SKILL_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_USER_SKILL_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_user_skill_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
              CREATE OR REPLACE PROCEDURE prc_etl_user_skill_daily
             AS
                v_count             NUMBER;
                v_notification_id   VARCHAR2(200);
                v_error             VARCHAR2(4000);
             BEGIN
    ------------------------------------------ 
    -- [1.] INSERT NOTIFICATION (IN_PROGRESS)
    ------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_USER_SKILL_DAILY_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'DAILY',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
     RETURNING notification_id INTO v_notification_id;
     COMMIT;
    ------------------------------------ 
    -- [2.] VALIDATE SOURCE TABLES SYNC
    ------------------------------------
 
    SELECT COUNT(*) INTO v_count
    FROM dual
    WHERE EXISTS ( SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_location 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_city 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_administrative_unit 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_administrative_unit_type 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_country 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                    SELECT 1 
                    FROM autonomous_dw_landing_owner.dwh_region 
                    WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                    SELECT 1 
                    FROM autonomous_dw_landing_owner.dwh_language 
                    WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                   ) AND EXISTS (
                     SELECT 1 
                     FROM autonomous_dw_landing_owner.dwh_currency 
                     WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                    ) AND EXISTS ( 
                     SELECT 1 
                     FROM autonomous_dw_landing_owner.dwh_institution 
                     WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                    ) AND EXISTS (
                     SELECT 1 
                     FROM autonomous_dw_landing_owner.dwh_specialization 
                     WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                    );
                    
    IF v_count = 0 THEN
        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = 'Source tables not synced today'
        WHERE notification_id = v_notification_id;
        COMMIT;
        RETURN;
    END IF;

    ------------------------- 
    -- [4.] MERGE DIM TABLE
    -------------------------

    MERGE INTO autonomous_dw_owner.dwh_user_skill_dim d
    USING (
            SELECT DISTINCT
                   sk.skill_code AS skill_code,
                   sk.name AS skill_name,
                   sk.prerequisite_knowledge AS prerequisite_knowledge_score,
                   sk.learning_difficulty AS learning_difficulty_score,
                   sk.implementation_difficulty AS implementation_difficulty_score,
                   sk.cross_platform_applicability AS cross_platform_applicability_score,
                   sk.rating AS skill_rating,
                   vers.version_code AS version_code,
                   vers.name AS version_name,
                   vers.release_date AS version_release_date,
                   vers.end_of_life AS version_end_of_life,
                   vers.developer_popularity AS developer_popularity_score,
                   vers.community_support AS community_support_score,
                   vers.industry_usage_score AS industry_usage_score,
                   vers.knowledge_score AS knowledge_score,
                   vers.skills_rating AS version_skill_rating,
                   vers.rating AS version_rating,
                   tech.technology_code AS technology_code,
                   tech.name AS technology_name,
                   tech.rating AS technology_rating,
                   tech_tp.technology_type_code AS technology_type_code,
                   tech_tp.name AS technology_type_name,
                   tech_tp.rating AS technology_type_rating
            FROM autonomous_dw_landing_owner.dwh_user_skill us
            JOIN autonomous_dw_landing_owner.dwh_skill sk ON us.skill_code = sk.skill_code
            JOIN autonomous_dw_landing_owner.dwh_version vers  ON sk.last_version_code = vers.version_code
            JOIN autonomous_dw_landing_owner.dwh_technology tech ON vers.technology_code = tech.technology_code
            JOIN autonomous_dw_landing_owner.dwh_technology_type tech_tp ON tech.technology_type_code = tech_tp.technology_type_code
            WHERE trunc(us.last_update_date)=trunc(sysdate-1)
  
           ) s
    ON (d.skill_code = s.skill_code)
    WHEN MATCHED THEN UPDATE SET

       d.skill_name                             = s.skill_name,
       d.prerequisite_knowledge_score           = s.prerequisite_knowledge_score,
       d.learning_difficulty_score              = s.learning_difficulty_score,
       d.implementation_difficulty_score        = s.implementation_difficulty_score,
       d.cross_platform_applicability_score     = s.cross_platform_applicability_score,
       d.skill_rating                           = s.skill_rating,
       d.version_code                           = s.version_code,
       d.version_name                           = s.version_name,
       d.version_release_date                   = s.version_release_date,
       d.version_end_of_life                    = s.version_end_of_life,
       d.developer_popularity_score             = s.developer_popularity_score,
       d.community_support_score                = s.community_support_score,
       d.industry_usage_score                   = s.industry_usage_score,
       d.knowledge_score                        = s.knowledge_score,
       d.version_skill_rating                   = s.version_skill_rating,
       d.version_rating                         = s.version_rating,
       d.technology_code                        = s.technology_code,
       d.technology_name                        = s.technology_name,
       d.technology_rating                      = s.technology_rating,
       d.technology_type_code                   = s.technology_type_code,
       d.technology_type_name                   = s.technology_type_name,
       d.technology_type_rating                 = s.technology_type_rating,
       d.deleted_flag                           = 'N',
       d.last_update_date                       = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

       skill_code,                    
       skill_name,  
       prerequisite_knowledge_score,     
       learning_difficulty_score,     
       implementation_difficulty_score,      
       cross_platform_applicability_score,   
       skill_rating,    
       version_code,   
       version_name,  
       version_release_date,      
       version_end_of_life,                    
       developer_popularity_score,            
       community_support_score,               
       industry_usage_score,                  
       knowledge_score,                      
       version_skill_rating,                 
       version_rating,                        
       technology_code,                       
       technology_name,                      
       technology_rating,                     
       technology_type_code,                  
       technology_type_name,                  
       technology_type_rating,                
       deleted_flag,
       creation_date,
       last_update_date
    )
    VALUES 
    (
       s.skill_code,                    
       s.skill_name,  
       s.prerequisite_knowledge_score,     
       s.learning_difficulty_score,     
       s.implementation_difficulty_score,      
       s.cross_platform_applicability_score,   
       s.skill_rating,    
       s.version_code,   
       s.version_name,  
       s.version_release_date,      
       s.version_end_of_life,                    
       s.developer_popularity_score,            
       s.community_support_score,               
       s.industry_usage_score,                  
       s.knowledge_score,                      
       s.version_skill_rating,                 
       s.version_rating,                        
       s.technology_code,                       
       s.technology_name,                      
       s.technology_rating,                     
       s.technology_type_code,                  
       s.technology_type_name,                  
       s.technology_type_rating,     
       'N',
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP
    );
    
    UPDATE autonomous_dw_owner.dwh_user_skill_dim d
    SET
           d.deleted_flag = 'Y',
           d.last_update_date = CURRENT_TIMESTAMP
    WHERE NOT EXISTS (
                       SELECT 1
                       FROM autonomous_dw_landing_owner.dwh_user_skill us
                           JOIN autonomous_dw_landing_owner.dwh_skill s ON us.skill_code = s.skill_code
                           JOIN autonomous_dw_landing_owner.dwh_version vers ON s.last_version_code = vers.version_code
                           JOIN autonomous_dw_landing_owner.dwh_technology tech ON vers.technology_code = tech.technology_code
                           JOIN autonomous_dw_landing_owner.dwh_technology_type tech_tp ON tech.technology_type_code = tech_tp.technology_type_code
                       WHERE s.skill_code = d.skill_code
                     )
    AND d.deleted_flag = 'N';

    COMMIT;

---------------------------------------------------------------------- 
-- [5.] SUCCESS NOTIFICATION
----------------------------------------------------------------------

    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'DONE',
        end_timestamp = CURRENT_TIMESTAMP
    WHERE notification_id = v_notification_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;

        v_error := SQLERRM;

        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = v_error
        WHERE notification_id = v_notification_id;

        COMMIT;

        RAISE_APPLICATION_ERROR(-20002, v_error);

END;
 ]';

EXECUTE IMMEDIATE v_sql;

--[1.] VERIFY IF THE PROCEDURE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_USER_SKILL_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_USER_SKILL_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_USER_SKILL_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_USER_SKILL_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_USER_SKILL_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_USER_SKILL_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_USER_SKILL_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_USER_SKILL_DIM'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_USER_SKILL_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

