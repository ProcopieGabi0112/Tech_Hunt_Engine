-- AUTONOMOUS_DB_ADMIN_JOB_PROCESSES_NOTIF_CLEAN_UP_1_v1.0.0
--"CLEAN UP JOB FOR PROCESSES_NOTIF TABLE"
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
WHERE job_name = 'JOB_CLEAN_PROCESSES_NOTIF';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('JOB_CLEAN_PROCESSES_NOTIF', FORCE => TRUE);
END IF;

--CREATE JOB
v_sql := q'[
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'JOB_CLEAN_PROCESSES_NOTIF',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'{
      BEGIN
        DELETE FROM autonomous_db_tech_owner.processes_notif
        WHERE creation_date < ADD_MONTHS(SYSTIMESTAMP, -3);
        COMMIT;
      END;
    }',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Deletes records older than 3 months from PROCESSES_NOTIF'
  );
END;
]';


EXECUTE IMMEDIATE v_sql;

--VERIFY JOB
SELECT COUNT(*) INTO v_count
FROM user_scheduler_jobs
WHERE job_name = 'JOB_CLEAN_PROCESSES_NOTIF';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The JOB_CLEAN_PROCESSES_NOTIF job wasnt created properly.');
END IF;

DBMS_OUTPUT.PUT_LINE('[3.] The JOB_CLEAN_PROCESSES_NOTIF cleanup job was created.');


  DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
