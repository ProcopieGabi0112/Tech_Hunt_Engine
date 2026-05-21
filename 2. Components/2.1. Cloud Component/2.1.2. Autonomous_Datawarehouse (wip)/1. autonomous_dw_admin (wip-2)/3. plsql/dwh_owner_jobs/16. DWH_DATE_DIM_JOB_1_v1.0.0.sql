--AUTONOMOUS_DW_OWNER_DWH_DATE_DIM_JOB_1_v1.0.0
--"DWH_DATE_DIM JOB"
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
AND object_name ='PRC_ETL_DATE_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_date_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
   CREATE OR REPLACE PROCEDURE prc_etl_date_initial_load
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
        'ETL_DATE_DAILY_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'DAILY',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
    RETURNING notification_id INTO v_notification_id;

    COMMIT;

    ----------------------------------------------------
    -- [2] INSERT ONLY NEW DATES
    ----------------------------------------------------
    INSERT INTO autonomous_dw_owner.dwh_date_dim (
        date_key,
        full_date,
        day_of_month,
        day_of_week,
        day_name,
        week_of_year,
        month_number,
        month_name,
        quarter,
        year,
        weekend_flag,
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
        TO_NUMBER(TO_CHAR(x.d,'YYYYMMDD')) AS date_key,
        x.d AS full_date,
        EXTRACT(DAY FROM x.d) AS day_of_month,
        TO_NUMBER(TO_CHAR(x.d,'D')) AS day_of_week,
        TRIM(TO_CHAR(x.d,'DAY')) AS day_name,
        TO_NUMBER(TO_CHAR(x.d,'WW')) AS week_of_year,
        EXTRACT(MONTH FROM x.d) AS month_number,
        TRIM(TO_CHAR(x.d,'MONTH')) AS month_name,
        TO_NUMBER(TO_CHAR(x.d,'Q')) AS quarter,
        EXTRACT(YEAR FROM x.d) AS year,
        CASE
            WHEN TO_CHAR(x.d,'D') IN ('1','7') THEN 'Y'
            ELSE 'N'
        END AS weekend_flag,
        CURRENT_TIMESTAMP,
        'ETL_DATE_PROCESS',
        CURRENT_TIMESTAMP,
        'ETL_DATE_PROCESS',
        CURRENT_TIMESTAMP,
        TO_TIMESTAMP(
            '9999-12-31 23:59:59',
            'YYYY-MM-DD HH24:MI:SS'
        ),
        'db_env',
        'N'
    FROM (
        SELECT DISTINCT apply_date AS d
        FROM autonomous_dw_landing_owner.dwh_job_application
        WHERE apply_date IS NOT NULL

        UNION

        SELECT DISTINCT creation_date AS d
        FROM autonomous_dw_landing_owner.dwh_job_application
        WHERE creation_date IS NOT NULL

        UNION

        SELECT DISTINCT last_update_date AS d
        FROM autonomous_dw_landing_owner.dwh_job_application
        WHERE last_update_date IS NOT NULL
    ) x
    WHERE NOT EXISTS (
        SELECT 1
        FROM autonomous_dw_owner.dwh_date_dim dd
        WHERE dd.date_key = TO_NUMBER(TO_CHAR(x.d,'YYYYMMDD'))
    );

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
AND object_name ='PRC_ETL_DATE_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_DATE_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_DATE_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_date_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_DATE_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_DATE_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_date_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
 CREATE OR REPLACE PROCEDURE prc_etl_date_daily
AS
    v_notification_id   VARCHAR2(200);
    v_error             VARCHAR2(4000);
BEGIN
    ----------------------------------------------------
    -- [1] NOTIFICATION
    ----------------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name, process_date, process_type,
        start_timestamp, status, admin_user
    )
    VALUES (
        'ETL_DATE_DAILY_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'DAILY',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
    RETURNING notification_id INTO v_notification_id;

    COMMIT;

    ----------------------------------------------------
    -- [2] INSERT ONLY NEW DATES FROM LANDING
    ----------------------------------------------------
    INSERT INTO autonomous_dw_owner.dwh_date_dim (
        date_key,
        full_date,
        day_of_month,
        day_of_week,
        day_name,
        week_of_year,
        month_number,
        month_name,
        quarter,
        year,
        weekend_flag,
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
        TO_NUMBER(TO_CHAR(x.d,'YYYYMMDD')) AS date_key,
        x.d AS full_date,
        EXTRACT(DAY FROM x.d) AS day_of_month,
        TO_NUMBER(TO_CHAR(x.d,'D')) AS day_of_week,
        TRIM(TO_CHAR(x.d,'DAY')) AS day_name,
        TO_NUMBER(TO_CHAR(x.d,'WW')) AS week_of_year,
        EXTRACT(MONTH FROM x.d) AS month_number,
        TRIM(TO_CHAR(x.d,'MONTH')) AS month_name,
        TO_NUMBER(TO_CHAR(x.d,'Q')) AS quarter,
        EXTRACT(YEAR FROM x.d) AS year,
        CASE WHEN TO_CHAR(x.d,'D') IN ('1','7') THEN 'Y' ELSE 'N' END AS weekend_flag,
        CURRENT_TIMESTAMP,
        'ETL_DATE_PROCESS',
        CURRENT_TIMESTAMP,
        'ETL_DATE_PROCESS',
        CURRENT_TIMESTAMP,
        TO_TIMESTAMP(
            '9999-12-31 23:59:59',
            'YYYY-MM-DD HH24:MI:SS'
        ),
        'db_env',
        'N'
        
    FROM (
        SELECT DISTINCT apply_date AS d
        FROM autonomous_dw_landing_owner.dwh_job_application
        WHERE apply_date IS NOT NULL
          AND TRUNC(apply_date) = TRUNC(SYSDATE - 1)

        UNION

        SELECT DISTINCT creation_date AS d
        FROM autonomous_dw_landing_owner.dwh_job_application
        WHERE creation_date IS NOT NULL
          AND TRUNC(creation_date) = TRUNC(SYSDATE - 1)

        UNION

        SELECT DISTINCT last_update_date AS d
        FROM autonomous_dw_landing_owner.dwh_job_application
        WHERE last_update_date IS NOT NULL
          AND TRUNC(last_update_date) = TRUNC(SYSDATE - 1)
    ) x
    WHERE NOT EXISTS (
        SELECT 1
        FROM autonomous_dw_owner.dwh_date_dim dd
        WHERE dd.date_key = TO_NUMBER(TO_CHAR(x.d,'YYYYMMDD'))
    );

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
AND object_name ='PRC_ETL_DATE_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_DATE_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_DATE_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_DATE_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_DATE_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_DATE_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_DATE_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_DATE_DIM'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_DATE_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

