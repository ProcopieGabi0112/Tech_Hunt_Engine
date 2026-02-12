-- AUTONOMOUS_DW_ADMIN_JOB_DWH_CONNECT_NOTIF_POPULATION_1_v1.0.0
--"POPULATION JOB FOR DWH_CONNECT_NOTIF TABLE"
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
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "ADMIN"	
-- Database_name: "FCEN3PO9"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDW)"

--CREATE SCHEDULER JOB FOR CLEANUP
--DELETE JOB IF EXISTS
SELECT COUNT(*) INTO v_count
FROM user_scheduler_jobs
WHERE job_name = 'JOB_POPULATION_DWH_CONNECT_NOTIF';
IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('JOB_POPULATION_DWH_CONNECT_NOTIF', FORCE => TRUE);
END IF;

--CREATE JOB
v_sql := q'[
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_POPULATION_DWH_CONNECT_NOTIF',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'!
      DECLARE
        TYPE t_session IS RECORD (
          sid        NUMBER,
          serial#    NUMBER,
          username   VARCHAR2(100),
          machine    VARCHAR2(100),
          program    VARCHAR2(100),
          status     VARCHAR2(20)
        );
        TYPE t_session_tab IS TABLE OF t_session INDEX BY PLS_INTEGER;
        v_sessions t_session_tab;
        v_key VARCHAR2(200);
        v_count NUMBER;
        i NUMBER := 0;
      BEGIN
        FOR r IN (
          SELECT sid, serial#, username, machine, program, status
          FROM gv$session
          WHERE username IS NOT NULL
          AND type = 'USER'
          AND username NOT IN ('SYS', 'SYSTEM', 'PDBADMIN')
          AND machine NOT LIKE '%oracle%'
          AND machine NOT LIKE '%vcn%'
          AND machine NOT LIKE '%adw%'
          AND machine NOT LIKE '%subnet%'
          AND program NOT LIKE '%JDBC%'
          AND program NOT LIKE '%(SYS)%'
          AND program NOT LIKE '%(PDBADMIN)%'

        ) LOOP
          i := i + 1;
          v_sessions(i).sid      := r.sid;
          v_sessions(i).serial#  := r.serial#;
          v_sessions(i).username := r.username;
          v_sessions(i).machine  := r.machine;
          v_sessions(i).program  := r.program;
          v_sessions(i).status   := r.status;
        END LOOP;

        FOR j IN 1 .. v_sessions.COUNT LOOP
          v_key := v_sessions(j).sid || '_' || v_sessions(j).serial# || '_' || v_sessions(j).username;

          SELECT COUNT(*) INTO v_count
          FROM autonomous_dw_tech_owner.dwh_connect_notif
          WHERE conn_key = v_key;

          IF v_count = 0 THEN
            INSERT INTO autonomous_dw_tech_owner.dwh_connect_notif (
              conn_key,
              user_name,
              start_conn_timestamp,
              end_conn_timestamp,
              schema,
              user_ip,
              action,
              created_by,
              source_system
            ) VALUES (
              v_key,
              v_sessions(j).username,
              SYSTIMESTAMP,
              NULL,
              v_sessions(j).username,
              v_sessions(j).machine,
              'LOGIN',
              'AUTONOMOUS_DATAWAREHOUSE_SYSTEM',
              'dw_env'
            );
          ELSIF v_sessions(j).status = 'INACTIVE' THEN
            UPDATE autonomous_dw_tech_owner.dwh_connect_notif
            SET end_conn_timestamp = SYSTIMESTAMP,
                action = 'LOGOUT'
            WHERE conn_key = v_key
              AND end_conn_timestamp IS NULL;
          END IF;
        END LOOP;
      END;
    !',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=5',
    enabled         => TRUE
  );
END;
]';


EXECUTE IMMEDIATE v_sql;

--VERIFY JOB
SELECT COUNT(*) INTO v_count
FROM user_scheduler_jobs
WHERE job_name = 'JOB_POPULATION_DWH_CONNECT_NOTIF';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The JOB_POPULATION_DWH_CONNECT_NOTIF job wasnt created properly.');
END IF;

DBMS_OUTPUT.PUT_LINE('[3.] The JOB_POPULATION_DWH_CONNECT_NOTIF job was created.');


  DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/


