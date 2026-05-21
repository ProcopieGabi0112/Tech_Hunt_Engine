--AUTONOMOUS_DW_OWNER_DWH_SPECIALIZATION_DIM_JOB_1_v1.0.0
--"DWH_SPECIALIZATION_DIM JOB"
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
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDW"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDB)"

-- CREATE IL PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_SPECIALIZATION_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_specialization_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
             CREATE OR REPLACE PROCEDURE prc_etl_specialization_initial_load
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
        'ETL_SPECIALIZATION_INITIAL_LOAD_PROCESS',
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
                   FROM autonomous_dw_landing_owner.dwh_specialization 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_institution 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_specialization_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_INSTITUTION_LOCATION_INITIAL_LOAD_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'INITIAL LOAD'
                   AND status = 'DONE'
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

    MERGE INTO autonomous_dw_owner.dwh_specialization_dim d
    USING (
       SELECT DISTINCT  
          s.specialization_id AS specialization_id,
          inst.institution_id AS institution_id,
          s.specialization_type_id AS specialization_type_id,
          s.name AS specialization_name,
          s.degree_type AS degree_type,
          s.employment_rate AS employment_rate, 
          s.teachers_feedback AS teachers_feedback, 
          s.courses_feedback AS courses_feedback, 
          s.entry_difficulty AS entry_difficulty,
          s.graduation_difficulty AS graduation_difficulty, 
          s.industry_reputation AS industry_reputation,
          s.rating AS specialization_rating,
          st.name AS specialization_type_name, 
          st.complexity_score AS specialization_type_score,
          inst.name AS institution_name, 
          inst.founding_year AS founding_year, 
          inst.rating AS institution_rating, 
          dw_inst_loc.institution_location_key AS institution_location_key
        FROM autonomous_dw_landing_owner.dwh_user_spec us
        JOIN autonomous_dw_landing_owner.dwh_specialization s
             ON us.specialization_id = s.specialization_id
        JOIN autonomous_dw_landing_owner.dwh_specialization_type st
             ON s.specialization_type_id = st.specialization_type_id
        JOIN autonomous_dw_landing_owner.dwh_institution inst
             ON s.institution_id = inst.institution_id
        JOIN autonomous_dw_owner.dwh_institution_location_dim dw_inst_loc
             ON inst.location_id = dw_inst_loc.location_address_code
       
               ) s
    ON (d.specialization_id = s.specialization_id)

    WHEN MATCHED THEN UPDATE SET

         
          d.institution_id                 = s.institution_id,
          d.specialization_type_id         = s.specialization_type_id,
          d.specialization_name            = s.specialization_name,
          d.degree_type                    = s.degree_type,
          d.employment_rate                = s.employment_rate, 
          d.teachers_feedback              = s.teachers_feedback, 
          d.courses_feedback               = s.courses_feedback, 
          d.entry_difficulty               = s.entry_difficulty,
          d.graduation_difficulty          = s.graduation_difficulty, 
          d.industry_reputation            = s.industry_reputation,
          d.specialization_rating          = s.specialization_rating,
          d.specialization_type_name       = s.specialization_type_name, 
          d.specialization_type_score      = s.specialization_type_score,
          d.institution_name               = s.institution_name, 
          d.founding_year                  = s.founding_year, 
          d.institution_rating             = s.institution_rating, 
          d.institution_location_key       = s.institution_location_key,
          d.deleted_flag                   = 'N',
          d.last_update_date               = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

          specialization_id,
          institution_id,
          specialization_type_id,
          specialization_name,
          degree_type,
          employment_rate, 
          teachers_feedback, 
          courses_feedback, 
          entry_difficulty,
          graduation_difficulty, 
          industry_reputation,
          specialization_rating,
          specialization_type_name, 
          specialization_type_score,
          institution_name, 
          founding_year, 
          institution_rating, 
          institution_location_key,
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
      s.specialization_id,
      s.institution_id,
      s.specialization_type_id,
      s.specialization_name,
      s.degree_type,
      s.employment_rate, 
      s.teachers_feedback, 
      s.courses_feedback, 
      s.entry_difficulty,
      s.graduation_difficulty, 
      s.industry_reputation,
      s.specialization_rating,
      s.specialization_type_name, 
      s.specialization_type_score,
      s.institution_name, 
      s.founding_year, 
      s.institution_rating, 
      s.institution_location_key,
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
AND object_name ='PRC_ETL_SPECIALIZATION_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_SPECIALIZATION_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_SPECIALIZATION_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_specialization_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_SPECIALIZATION_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_SPECIALIZATION_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_specialization_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
              CREATE OR REPLACE PROCEDURE prc_etl_specialization_daily
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
        'ETL_SPECIALIZATION_DAILY_PROCESS',
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
                   FROM autonomous_dw_landing_owner.dwh_specialization 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_institution 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_specialization_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_INSTITUTION_LOCATION_DAILY_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'DAILY'
                   AND status = 'DONE'
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

    
    MERGE INTO autonomous_dw_owner.dwh_specialization_dim d
    USING (
       SELECT DISTINCT  
          s.specialization_id AS specialization_id,
          inst.institution_id AS institution_id,
          s.specialization_type_id AS specialization_type_id,
          s.name AS specialization_name,
          s.degree_type AS degree_type,
          s.employment_rate AS employment_rate, 
          s.teachers_feedback AS teachers_feedback, 
          s.courses_feedback AS courses_feedback, 
          s.entry_difficulty AS entry_difficulty,
          s.graduation_difficulty AS graduation_difficulty, 
          s.industry_reputation AS industry_reputation,
          s.rating AS specialization_rating,
          st.name AS specialization_type_name, 
          st.complexity_score AS specialization_type_score,
          inst.name AS institution_name, 
          inst.founding_year AS founding_year, 
          inst.rating AS institution_rating, 
          dw_inst_loc.institution_location_key AS institution_location_key
        FROM autonomous_dw_landing_owner.dwh_user_spec us
        JOIN autonomous_dw_landing_owner.dwh_specialization s
             ON us.specialization_id = s.specialization_id
        JOIN autonomous_dw_landing_owner.dwh_specialization_type st
             ON s.specialization_type_id = st.specialization_type_id
        JOIN autonomous_dw_landing_owner.dwh_institution inst
             ON s.institution_id = inst.institution_id
        JOIN autonomous_dw_owner.dwh_institution_location_dim dw_inst_loc
             ON inst.location_id = dw_inst_loc.location_address_code
        WHERE TRUNC(us.last_update_date) = TRUNC(SYSDATE-1)
       
               ) s
    ON (d.specialization_id = s.specialization_id)

    WHEN MATCHED THEN UPDATE SET

          
          d.institution_id                 = s.institution_id,
          d.specialization_type_id         = s.specialization_type_id,
          d.specialization_name            = s.specialization_name,
          d.degree_type                    = s.degree_type,
          d.employment_rate                = s.employment_rate, 
          d.teachers_feedback              = s.teachers_feedback, 
          d.courses_feedback               = s.courses_feedback, 
          d.entry_difficulty               = s.entry_difficulty,
          d.graduation_difficulty          = s.graduation_difficulty, 
          d.industry_reputation            = s.industry_reputation,
          d.specialization_rating          = s.specialization_rating,
          d.specialization_type_name       = s.specialization_type_name, 
          d.specialization_type_score      = s.specialization_type_score,
          d.institution_name               = s.institution_name, 
          d.founding_year                  = s.founding_year, 
          d.institution_rating             = s.institution_rating, 
          d.institution_location_key       = s.institution_location_key,
          d.deleted_flag                   = 'N',
          d.last_update_date               = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

          specialization_id,
          institution_id,
          specialization_type_id,
          specialization_name,
          degree_type,
          employment_rate, 
          teachers_feedback, 
          courses_feedback, 
          entry_difficulty,
          graduation_difficulty, 
          industry_reputation,
          specialization_rating,
          specialization_type_name, 
          specialization_type_score,
          institution_name, 
          founding_year, 
          institution_rating, 
          institution_location_key,
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
      s.specialization_id,
      s.institution_id,
      s.specialization_type_id,
      s.specialization_name,
      s.degree_type,
      s.employment_rate, 
      s.teachers_feedback, 
      s.courses_feedback, 
      s.entry_difficulty,
      s.graduation_difficulty, 
      s.industry_reputation,
      s.specialization_rating,
      s.specialization_type_name, 
      s.specialization_type_score,
      s.institution_name, 
      s.founding_year, 
      s.institution_rating, 
      s.institution_location_key,
      'N',
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
);
    
    
    UPDATE autonomous_dw_owner.dwh_specialization_dim d
    SET
           d.deleted_flag = 'Y',
           d.last_update_date = CURRENT_TIMESTAMP
    WHERE NOT EXISTS (
                       SELECT 1
                       FROM autonomous_dw_landing_owner.dwh_user_spec us
                       JOIN autonomous_dw_landing_owner.dwh_specialization s ON us.specialization_id = s.specialization_id
                       WHERE s.specialization_id = d.specialization_id
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
AND object_name ='PRC_ETL_SPECIALIZATION_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_SPECIALIZATION_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_SPECIALIZATION_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_SPECIALIZATION_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_SPECIALIZATION_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_SPECIALIZATION_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_SPECIALIZATION_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_SPECIALIZATION_DIM'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_SPECIALIZATION_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

