-- AUTONOMOUS_DB_ADMIN_JOB_RESOURCES_NOTIF_POPULATION_1_v1.0.0
-- "POPULATION JOB FOR RESOURCES_NOTIF TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_sql   CLOB;
BEGIN
  DBMS_OUTPUT.PUT_LINE('[1.] Script running...');
  ---------------------------------------
  -- [1.] CHECK CURRENT USER AND SCHEMA
  ---------------------------------------
  SELECT COUNT(*) INTO v_count
  FROM v$database
  WHERE sys_context('USERENV', 'SESSION_USER') = 'ADMIN'
    AND name = 'FCEN3PO9'
    AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');

  -----------------------------
  -- [2.] DROP JOB IF EXISTS
  -----------------------------
  SELECT COUNT(*) INTO v_count
  FROM user_scheduler_jobs
  WHERE job_name = 'JOB_POPULATION_RESOURCES_NOTIF';

  IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('JOB_POPULATION_RESOURCES_NOTIF', FORCE => TRUE);
  END IF;
  -----------------------------------------------
  -- [3.] CREATE OR REPLACE PROCEDURE JOB LOGIC
  -----------------------------------------------
EXECUTE IMMEDIATE q'[
    CREATE OR REPLACE PROCEDURE admin.proc_population_resources_notif AS
      v_start_ts   TIMESTAMP := SYSTIMESTAMP;
      v_end_ts     TIMESTAMP;
      v_deleted    NUMBER := 0;
      v_exists     NUMBER := 0;
      v_error_msg  VARCHAR2(4000);

      CURSOR c_ts IS
        SELECT tablespace_name,
               ROUND(used_space * block_size / 1024 / 1024) AS used_mb,
               ROUND((tablespace_size - used_space) * block_size / 1024 / 1024) AS free_mb,
               ROUND(tablespace_size * block_size / 1024 / 1024) AS total_mb
        FROM dba_tablespace_usage_metrics;
    BEGIN
      --------------------------------------------------------------
      -- 1. Insert IN_PROGRESS notification
      --------------------------------------------------------------
      INSERT INTO autonomous_db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, status, admin_user
      ) VALUES (
        'RESOURCES_NOTIF_POPULATION_PROCESS',
        TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
        'POPULATION',
        v_start_ts,
        'IN_PROGRESS',
        'AUTONOMOUS_DATABASE_SYSTEM'
      );

      COMMIT;

      --------------------------------------------------------------
      -- 3. Population logic
      --------------------------------------------------------------
      FOR r IN c_ts LOOP
        INSERT INTO autonomous_db_tech_owner.resources_notif (
          snapshot_timestamp, tablespace_name, total_space_mb,
          used_space_mb, free_space_mb, usage_percentage,
          creation_date, created_by, source_system
        ) VALUES (
          SYSTIMESTAMP,
          r.tablespace_name,
          r.total_mb,
          r.used_mb,
          r.free_mb,
          ROUND(r.used_mb * 100 / r.total_mb, 2),
          CURRENT_TIMESTAMP,
          'AUTONOMOUS_DATABASE_SYSTEM',
          'db_env'
        );
      END LOOP;

      v_deleted := SQL%ROWCOUNT;
      v_end_ts := SYSTIMESTAMP;

      --------------------------------------------------------------
      -- 4. Insert DONE notification
      --------------------------------------------------------------
      INSERT INTO autonomous_db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
      ) VALUES (
        'RESOURCES_NOTIF_POPULATION_PROCESS',
        TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
        'POPULATION',
        v_start_ts,
        v_end_ts,
        'DONE',
        'Deleted ' || v_deleted || ' rows older than 3 days',
        'AUTONOMOUS_DATABASE_SYSTEM'
      );

      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        v_end_ts := SYSTIMESTAMP;
        v_error_msg := SUBSTR(SQLERRM, 1, 3500);

        INSERT INTO autonomous_db_tech_owner.processes_notif (
          process_name, process_date, process_type,
          start_timestamp, end_timestamp, status,
          error_message, admin_user
        ) VALUES (
          'RESOURCES_NOTIF_POPULATION_PROCESS',
          TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
          'POPULATION',
          v_start_ts,
          v_end_ts,
          'ERROR',
          v_error_msg,
          'AUTONOMOUS_DATABASE_SYSTEM'
        );

        COMMIT;
        RAISE;
    END;
  ]';

   ---------------------------------------
  -- [4.] CREATE JOB USING THE PROCEDURE
  ---------------------------------------
   DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_POPULATION_RESOURCES_NOTIF',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'proc_population_resources_notif',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=HOURLY; INTERVAL=1',
    enabled         => TRUE,
    comments        => 'Populate the RESOURCES_NOTIF table'
  );
  ---------------------
  -- [5.] VERIFY JOB
  ---------------------
  SELECT COUNT(*) INTO v_count
  FROM user_scheduler_jobs
  WHERE job_name = 'JOB_POPULATION_RESOURCES_NOTIF';

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The JOB_POPULATION_RESOURCES_NOTIF job wasn''t created properly.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('[3.] The JOB_POPULATION_RESOURCES_NOTIF job was created.');
  DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
