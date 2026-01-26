-- AUTONOMOUS_DB_ADMIN_JOB_RESOURCES_NOTIF_POPULATION_1_v1.0.0
-- "POPULATION JOB FOR RESOURCES_NOTIF TABLE"

SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_sql   CLOB;
BEGIN
  DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

  -- [1.] CHECK CURRENT USER AND SCHEMA
  SELECT COUNT(*) INTO v_count
  FROM v$database
  WHERE sys_context('USERENV', 'SESSION_USER') = 'ADMIN'
    AND name = 'FCEN3PO9'
    AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');

  -- DELETE JOB IF EXISTS
  SELECT COUNT(*) INTO v_count
  FROM user_scheduler_jobs
  WHERE job_name = 'JOB_POPULATION_RESOURCES_NOTIF';

  IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('JOB_POPULATION_RESOURCES_NOTIF', FORCE => TRUE);
  END IF;

  -- CREATE JOB
  v_sql := q'[
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_POPULATION_RESOURCES_NOTIF',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'! 
      DECLARE
        CURSOR c_ts IS
          SELECT tablespace_name,
                 ROUND(used_space * block_size / 1024 / 1024) AS used_mb,
                 ROUND((tablespace_size - used_space) * block_size / 1024 / 1024) AS free_mb,
                 ROUND(tablespace_size * block_size / 1024 / 1024) AS total_mb
          FROM dba_tablespace_usage_metrics;
      BEGIN
        FOR r IN c_ts LOOP
          INSERT INTO autonomous_db_tech_owner.resources_notif (
            snapshot_timestamp,
            tablespace_name,
            total_space_mb,
            used_space_mb,
            free_space_mb,
            usage_percentage,
            creation_date,
            created_by,
            source_system
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
      END;
    !',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=HOURLY; INTERVAL=5',
    enabled         => TRUE
  );
END;
]';

  EXECUTE IMMEDIATE v_sql;

  -- VERIFY JOB
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
