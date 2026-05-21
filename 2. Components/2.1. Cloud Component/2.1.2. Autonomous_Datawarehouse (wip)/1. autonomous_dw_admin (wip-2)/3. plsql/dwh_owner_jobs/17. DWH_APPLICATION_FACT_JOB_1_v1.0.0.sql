--AUTONOMOUS_DW_OWNER_DWH_APPLICATION_FACT_JOB_1_v1.0.0
--"DWH_APPLICATION_FACT JOB"
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
AND object_name ='PRC_ETL_APPLICATION_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_application_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
   CREATE OR REPLACE PROCEDURE prc_etl_application_initial_load
AS
    v_notification_id   VARCHAR2(200);
    v_error             VARCHAR2(4000);
BEGIN
    ----------------------------------------------------
    -- [1] NOTIFICATION
    ----------------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_APPLICATION_INITIAL_LOAD_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'INITIAL LOAD',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
    RETURNING notification_id INTO v_notification_id;

    COMMIT;

    ----------------------------------------------------
    -- [2] INSERT APPLICATION FACT RECORDS
    ----------------------------------------------------
    INSERT INTO autonomous_dw_owner.dwh_application_fact (
        application_id,
        user_key,
        job_key,
        date_key,
        salary,
        application_status,
        --match_score,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        valid_from,
        valid_to,
        source_system,
        deleted_flag
    )
    SELECT
        src.application_id,
        usr.user_key,
        job.job_key,
        dt.date_key,
        src.salary,
        src.status,
        --src.match_score,
        CURRENT_TIMESTAMP,
        'ETL_APPLICATION_FACT',
        CURRENT_TIMESTAMP,
        'ETL_APPLICATION_FACT',
        CURRENT_TIMESTAMP,
        TO_TIMESTAMP('9999-12-31 23:59:59','YYYY-MM-DD HH24:MI:SS'),
        'db_env',
        'N'
    FROM autonomous_dw_landing_owner.dwh_job_application src
    JOIN autonomous_dw_owner.dwh_user_dim usr
        ON usr.user_id = src.user_id
    JOIN autonomous_dw_owner.dwh_job_dim job
        ON job.job_id = src.job_id
    JOIN autonomous_dw_owner.dwh_date_dim dt
        ON dt.full_date = TRUNC(src.creation_date);

    COMMIT;

    ----------------------------------------------------
    -- [3] SUCCESS
    ----------------------------------------------------
    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'DONE',
        end_timestamp = CURRENT_TIMESTAMP
    WHERE notification_id = v_notification_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
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
AND object_name ='PRC_ETL_APPLICATION_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_APPLICATION_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_APPLICATION_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_application_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_APPLICATION_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_APPLICATION_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_application_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
    CREATE OR REPLACE PROCEDURE prc_etl_application_daily
AS
    v_notification_id   VARCHAR2(200);
    v_error             VARCHAR2(4000);
BEGIN
    ----------------------------------------------------
    -- [1] NOTIFICATION
    ----------------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_APPLICATION_INITIAL_LOAD_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'INITIAL LOAD',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
    RETURNING notification_id INTO v_notification_id;

    COMMIT;

    ----------------------------------------------------
    -- [2] INSERT APPLICATION FACT RECORDS
    ----------------------------------------------------
    INSERT INTO autonomous_dw_owner.dwh_application_fact (
        application_id,
        user_key,
        job_key,
        date_key,
        salary,
        application_status,
        --match_score,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        valid_from,
        valid_to,
        source_system,
        deleted_flag
    )
    SELECT
        src.application_id,
        usr.user_key,
        job.job_key,
        dt.date_key,
        src.salary,
        src.status,
        --src.match_score,
        CURRENT_TIMESTAMP,
        'ETL_APPLICATION_FACT',
        CURRENT_TIMESTAMP,
        'ETL_APPLICATION_FACT',
        CURRENT_TIMESTAMP,
        TO_TIMESTAMP('9999-12-31 23:59:59','YYYY-MM-DD HH24:MI:SS'),
        'db_env',
        'N'
    FROM autonomous_dw_landing_owner.dwh_job_application src
    JOIN autonomous_dw_owner.dwh_user_dim usr
        ON usr.user_id = src.user_id
    JOIN autonomous_dw_owner.dwh_job_dim job
        ON job.job_id = src.job_id
    JOIN autonomous_dw_owner.dwh_date_dim dt
        ON dt.full_date = TRUNC(src.creation_date);

    COMMIT;

    ----------------------------------------------------
    -- [3] SUCCESS
    ----------------------------------------------------
    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'DONE',
        end_timestamp = CURRENT_TIMESTAMP
    WHERE notification_id = v_notification_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
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
AND object_name ='PRC_ETL_APPLICATION_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_APPLICATION_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_APPLICATION_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_APPLICATION_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_APPLICATION_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_APPLICATION_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_APPLICATION_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_APPLICATION_FACT'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_APPLICATION_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

