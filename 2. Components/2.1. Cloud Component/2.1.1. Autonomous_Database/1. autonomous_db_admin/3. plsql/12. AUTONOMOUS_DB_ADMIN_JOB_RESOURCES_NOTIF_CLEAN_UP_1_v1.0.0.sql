-- AUTONOMOUS_DB_ADMIN_JOB_RESOURCES_NOTIF_CLEAN_UP_1_v1.0.0
--"CLEAN UP JOB FOR RESOURCES_NOTIF TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_exists NUMBER;
  v_sql CLOB;
BEGIN
  DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--[1.] CHECK CURRENT USER AND SCHEMA
SELECT COUNT(*) INTO v_count
FROM v$database
WHERE sys_context('USERENV', 'SESSION_USER') = 'ADMIN'
AND name = 'FCEN3PO9'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "ADMIN"	
-- Database_name: "FCEN3PO9"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--CREATE SCHEDULER JOB FOR CLEANUP
--DELETE JOB IF EXISTS
SELECT COUNT(*) INTO v_count
FROM user_scheduler_jobs
WHERE job_name = 'JOB_CLEAN_RESOURCES_NOTIF';
IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('JOB_CLEAN_RESOURCES_NOTIF', FORCE => TRUE);
END IF;

--CREATE JOB
v_sql := q'[
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'JOB_CLEAN_RESOURCES_NOTIF',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'{
      DECLARE
        v_start_ts   TIMESTAMP := SYSTIMESTAMP;
        v_end_ts TIMESTAMP;
        v_deleted NUMBER := 0;
        v_exists NUMBER := 0;
        v_error_msg VARCHAR2(4000);
      BEGIN
        ---------------------------------------------- 
        -- 1. Verificăm dacă există rânduri de șters 
        ----------------------------------------------
        SELECT COUNT(*) INTO v_exists 
        FROM autonomous_db_tech_owner.processes_notif 
        WHERE creation_date < SYSTIMESTAMP - INTERVAL '3' DAY;
        ------------------------------------------------------
        -- 2. Dacă nu există → SKIP complet (fără notificări) 
        ------------------------------------------------------
        IF v_exists = 0 THEN 
           RETURN; 
        END IF;
        -------------------------------
        -- 3. Notification IN_PROGRESS 
        ------------------------------- 
        INSERT INTO autonomous_db_tech_owner.processes_notif 
        (process_name, 
         process_date, 
         process_type, 
         start_timestamp, 
         status, 
         admin_user 
         ) VALUES ( 
         'RESOURCES_NOTIF_CLEAN_UP_PROCESS', 
         TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 
         'CLEAN_UP', 
         v_start_ts, 
         'IN_PROGRESS', 
         'AUTONOMOUS_DATABASE_SYSTEM'); 

        COMMIT;
        -------------------- 
        -- 4. Cleanup logic 
        -------------------- 
        DELETE FROM autonomous_db_tech_owner.resources_notif 
        WHERE creation_date < SYSTIMESTAMP - INTERVAL '3' DAY;

        v_deleted := SQL%ROWCOUNT; 
        v_end_ts := SYSTIMESTAMP;
        ------------------------- 
        -- 5. Notification DONE 
        -------------------------
        INSERT INTO autonomous_db_tech_owner.processes_notif 
         (process_name, 
          process_date, 
          process_type, 
          start_timestamp, 
          end_timestamp, 
          status, 
          error_message, 
          admin_user 
          ) VALUES ( 
          'RESOURCES_NOTIF_CLEAN_UP_PROCESS', 
          TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 
          'CLEAN_UP', 
          v_start_ts, 
          v_end_ts, 
          'DONE', 
          'Deleted ' || v_deleted || ' rows older than 3 days', 
          'AUTONOMOUS_DATABASE_SYSTEM'); 
           
          COMMIT;

      EXCEPTION 
          WHEN OTHERS THEN 
               v_end_ts := SYSTIMESTAMP; 
               v_error_msg := SUBSTR(SQLERRM, 1, 3500);
               -------------------------- 
               -- 6. Notification ERROR 
               --------------------------
               INSERT INTO autonomous_db_tech_owner.processes_notif 
               (process_name, 
                process_date, 
                process_type, 
                start_timestamp, 
                end_timestamp, 
                status, 
                error_message, 
                admin_user 
               ) VALUES ( 
                'RESOURCES_NOTIF_CLEAN_UP_PROCESS',
                TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 
                'CLEAN_UP', 
                v_start_ts, 
                v_end_ts, 
                'ERROR', 
                v_error_msg, 
               'AUTONOMOUS_DATABASE_SYSTEM'); 
                COMMIT; 
                RAISE;

END;

    }',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Deletes records older than 3 days from RESOURCES_NOTIF table'
  );
END;
]';


EXECUTE IMMEDIATE v_sql;

--VERIFY JOB
SELECT COUNT(*) INTO v_count
FROM user_scheduler_jobs
WHERE job_name = 'JOB_CLEAN_RESOURCES_NOTIF';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The JOB_CLEAN_RESOURCES_NOTIF job wasnt created properly.');
END IF;

DBMS_OUTPUT.PUT_LINE('[3.] The JOB_CLEAN_RESOURCES_NOTIF job was created.');


  DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
