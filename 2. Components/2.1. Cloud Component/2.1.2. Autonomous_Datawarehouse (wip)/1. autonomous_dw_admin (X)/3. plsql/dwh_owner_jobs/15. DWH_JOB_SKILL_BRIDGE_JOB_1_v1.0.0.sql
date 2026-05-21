--AUTONOMOUS_DW_OWNER_DWH_JOB_SKILL_BRIDGE_JOB_1_v1.0.0
--"DWH_JOB_SKILL_BRIDGE JOB"
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
AND object_name ='PRC_ETL_JOB_SKILL_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_job_skill_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
             CREATE OR REPLACE PROCEDURE prc_etl_job_skill_initial_load
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
        'ETL_JOB_SKILL_INITIAL_LOAD_PROCESS',
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
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_SKILL_INITIAL_LOAD_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'INITIAL LOAD'
                   AND status = 'DONE'
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_USER_INITIAL_LOAD_PROCESS' 
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

    MERGE INTO autonomous_dw_owner.dwh_job_skill_bridge d
    USING (
       SELECT DISTINCT 
              skill_dim.job_skill_key,
              job_dim.job_key,
              us.required_level,
              us.importance_weight,
              us.is_mandatory,
              us.min_experience_months,
              us.max_months_since_used
        FROM autonomous_dw_landing_owner.dwh_job_skill us
        JOIN autonomous_dw_owner.dwh_job_skill_dim skill_dim ON us.skill_code = skill_dim.skill_code
        JOIN autonomous_dw_owner.dwh_job_dim job_dim ON us.job_id = job_dim.job_id
       
               ) s
    ON (d.job_skill_key = s.job_skill_key 
    AND d.job_key = s.job_key)

    WHEN MATCHED THEN UPDATE SET

              d.required_level = s.required_level,
              d.importance_weight = s.importance_weight,
              d.is_mandatory = s.is_mandatory,
              d.min_experience_months =s.min_experience_months,
              d.max_months_since_used = s.max_months_since_used,
              d.deleted_flag        = 'N',
              d.last_update_date    = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

          job_key,
          job_skill_key,
        required_level,
        importance_weight,
        is_mandatory ,
        min_experience_months,
        max_months_since_used,

          
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
      s.job_key,
          s.job_skill_key,
        s.required_level,
        s.importance_weight,
        s.is_mandatory ,
        s.min_experience_months,
        s.max_months_since_used,
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
AND object_name ='PRC_ETL_JOB_SKILL_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The prc_etl_job_skill_initial_load procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The prc_etl_job_skill_initial_load procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_job_skill_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The prc_etl_job_skill_initial_load is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_JOB_SKILL_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_job_skill_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
              CREATE OR REPLACE PROCEDURE prc_etl_job_skill_daily
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
        'ETL_JOB_SKILL_DAILY_PROCESS',
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
  INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_JOB_SKILL_DAILY_PROCESS',
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
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_SKILL_INITIAL_LOAD_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'INITIAL LOAD'
                   AND status = 'DONE'
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_USER_INITIAL_LOAD_PROCESS' 
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

    MERGE INTO autonomous_dw_owner.dwh_job_skill_bridge d
    USING (
       SELECT DISTINCT 
              skill_dim.job_skill_key,
              job_dim.job_key,
              us.required_level,
              us.importance_weight,
              us.is_mandatory,
              us.min_experience_months,
              us.max_months_since_used
        FROM autonomous_dw_landing_owner.dwh_job_skill us
        JOIN autonomous_dw_owner.dwh_job_skill_dim skill_dim ON us.skill_code = skill_dim.skill_code
        JOIN autonomous_dw_owner.dwh_job_dim job_dim ON us.job_id = job_dim.job_id
       
               ) s
    ON (d.job_skill_key = s.job_skill_key 
    AND d.job_key = s.job_key)

    WHEN MATCHED THEN UPDATE SET

              d.required_level = s.required_level,
              d.importance_weight = s.importance_weight,
              d.is_mandatory = s.is_mandatory,
              d.min_experience_months =s.min_experience_months,
              d.max_months_since_used = s.max_months_since_used,
              d.deleted_flag        = 'N',
              d.last_update_date    = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

          job_key,
          job_skill_key,
        required_level,
        importance_weight,
        is_mandatory ,
        min_experience_months,
        max_months_since_used,

          
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
      s.job_key,
          s.job_skill_key,
        s.required_level,
        s.importance_weight,
        s.is_mandatory ,
        s.min_experience_months,
        s.max_months_since_used,
      'N',
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
);
    
  
    UPDATE autonomous_dw_owner.dwh_job_skill_bridge d
    SET
           d.deleted_flag = 'Y',
           d.last_update_date = CURRENT_TIMESTAMP
    WHERE NOT EXISTS (
                       SELECT 1
                       FROM autonomous_dw_landing_owner.dwh_job_skill us
                            JOIN autonomous_dw_owner.dwh_job_skill_dim skill_dim ON us.skill_code = skill_dim.skill_code
                            JOIN autonomous_dw_owner.dwh_job_dim job_dim ON us.job_id = job_dim.job_id
                       WHERE skill_dim.job_skill_key  = d.job_skill_key 
                       AND job_dim.job_key = d.job_key
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
AND object_name ='PRC_ETL_JOB_SKILL_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_JOB_SKILL_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_JOB_SKILL_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_JOB_SKILL_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_JOB_SKILL_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_JOB_SKILL_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_JOB_SKILL_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_JOB_SKILL_BRIDGE'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_JOB_SKILL_DAILY  scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

