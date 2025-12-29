SET SERVEROUTPUT ON;
--RUNS INTO ADMIN SCHEMA ON CLOUD DATABASE
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_exists NUMBER;
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
--SELECT sys_context('USERENV', 'SESSION_USER') AS current_user,
--       name AS database_name,
--       sys_context('USERENV', 'CON_NAME') AS current_container,
--       CASE 
--           WHEN cdb = 'YES' AND sys_context('USERENV', 'CON_NAME') = 'CDB$ROOT' 
--           THEN 'Container Database (CDB)' 
--           ELSE 'Pluggable Database (PDB)' 
--       END AS database_type
--FROM v$database;
-- Current_User: "ADMIN"	
-- Database_name: "FCEN3PO9"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

----[2.] CHECK CDB_DATABASE STATUS
SELECT COUNT(*) INTO v_count
FROM v$database,v$instance
WHERE name = 'FCEN3PO9'
AND open_mode = 'READ WRITE'
AND status = 'OPEN'
AND cdb = 'YES';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The CDB database is not running properly.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[3.] The CDB database is running...');
--SELECT name db_name,
--             open_mode state,
--             status db_status,
--             cdb final_status 
--FROM v$database,v$instance;
---- Database_Name: "FCEN3PO9"	
---- Database_State: "READ WRITE"
---- Database_Status: "OPEN"
---- Database_Final_Status: "YES"

----[3.] CHECK PDB_DATABASE STATUS
SELECT COUNT(*) INTO v_count 
FROM v$pdbs v 
INNER JOIN cdb_pdbs c 
ON v.name = c.pdb_name
WHERE c.pdb_name = 'G90CE4847B77DFA_TECHHUNTENGINEDB'
AND c.status = 'NORMAL'
AND v.open_mode = 'READ WRITE';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PDB database is not running properly.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[4.] The PDB database is running...');

--SELECT c.pdb_id no,
--             c.pdb_name pluggable_db_name,
--             c.status status,
--             v.open_mode open_mode,
--             TO_CHAR(v.open_time,'yyyy-mm-dd HH24:MI:SS') AS open_time 
--FROM v$pdbs v 
--INNER JOIN cdb_pdbs c 
--ON v.name = c.pdb_name;
---- Pluggable_Database_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
---- Database_Status: "NORMAL"
---- Database_Open_Mode: "READ WRITE"
---- Open Time: "2025-10-08 15:57:09"

----[4.] CHECK DATABASE TABLESPACE

--SELECT 
--       --f.con_id||'/'||f.file_id||'/'||v.file# con_file_id,
--       f.tablespace_name,
--       --f.file_name,
--       ROUND(f.bytes / 1024 / 1024, 2) AS size_mb,
--       ROUND(f.bytes / 1024 / 1024 / 1024, 2) AS size_gb,
--       --p.pdb_name,
--       f.status ||' - '|| v.status ||' - '||v.enabled as status
--FROM   cdb_data_files f
--FULL JOIN   cdb_pdbs p ON f.con_id = p.con_id
--FULL JOIN   v$datafile v ON f.file_id = v.file#
--ORDER BY f.con_id;
---- TABLESPACE_NAME  SIZE_MB   SIZE_GB   STATUS
---- SYSTEM	     	1281	  1.25		AVAILABLE - SYSTEM - READ WRITE
---- SYSAUX	     	2090	  2.04		AVAILABLE - ONLINE - READ WRITE
---- SAMPLESCHEMA		204800	  200	    AVAILABLE - ONLINE - READ ONLY
---- DATA	        	1124	  1.17   	AVAILABLE - ONLINE - READ WRITE
---- DBFS_DATA		100	      0.1		AVAILABLE - ONLINE - READ WRITE
---- UNDOTBS1	     	1635	  1.6		AVAILABLE - ONLINE - READ WRITE

----[5.] VERIFY ACTIVE USERS
--SELECT 
--username AS USER_NAME,
--status AS USER_STATUS,
--osuser AS windows_user_name,
--machine AS windows_machine_name,
--program AS tool,
--TO_CHAR(logon_time, 'yyyy-mm-dd HH24:MI:SS') AS session_start_at,
--TO_CHAR(sql_exec_start, 'yyyy-mm-dd HH24:MI:SS') AS sql_start_at,
--TO_CHAR(prev_exec_start, 'yyyy-mm-dd HH24:MI:SS') AS last_session_start_at
--FROM V$SESSION
--WHERE username <> 'OML$METADATA';
---- USER_NAME: "ADMIN"	
---- USER_STATUS: "ACTIVE"	
---- WINDOWS_USER_NAME: "dproc"	
---- WINDOWS_MACHINE_NAME: "DESKTOP-POD05B4"	
---- TOOL_CONECTARE: "SQL Developer"	
---- Data_conectare:   "2025-10-08 19:59:14"	
---- Data_rulare_sql:  "2025-10-08 20:29:48"	
---- Ultima_conectare: "2025-10-08 20:29:34"
----[6.] VERIFY ALL SQL COMMANDS THAT RUNS IN THE LAST TWO HOURS
--SELECT
--  parsing_schema_name            AS "Schema",
--  executions                     AS "Nr_Executii",
--  ROUND(elapsed_time / 1000000, 2) AS "Timp_Total_Secunde",
--  ROUND(cpu_time / 1000000, 2) AS "Timp_CPU_Secunde",
--  disk_reads                     AS "Citiri_Disc",
--  buffer_gets                    AS "Citiri_Buffer",
--  rows_processed                 AS "Randuri_Procesate",
--  parse_calls                    AS "Nr_Parsari",
--  ROUND(sharable_mem / 1024, 2)  AS "Memorie_Shareble_KB",
--  ROUND(persistent_mem / 1024, 2) AS "Memorie_Persistenta_KB",
--  action                         AS "Actiune",
--  sql_text                       AS "Text_SQL",
--  REPLACE(FIRST_LOAD_TIME,'/',' ') AS "Incarcat_la" ,
--  REPLACE(LAST_ACTIVE_TIME,'/',' ') AS "Ultima_activitate",
--  ROUND(elapsed_time / 1000000, 2) AS "Timp_total_secunde",
--  ROUND(cpu_time / 1000000, 2) AS "Timp_CPU_secunde"
--  FROM v$sql
--WHERE executions > 0 
--AND parsing_schema_name = 'ADMIN' 
--AND LAST_ACTIVE_TIME >= SYSDATE - INTERVAL '2' HOUR
--ORDER BY elapsed_time DESC
--FETCH FIRST 150 ROWS ONLY;
----[7.] VERIFY ALL USERS
--SELECT username
--FROM all_users
--WHERE username IN ('ADMIN')
--ORDER BY username;
----[8.] AND ALL THE PRIVILEGIES 
--SELECT
--  u.username               AS "User",
--  u.account_status         AS "Status_Cont",
--  TO_CHAR(u.created, 'DD-MM-YYYY HH24:MI:SS') AS "Creat_la",
--  rp.granted_role          AS "Rol_Atribuit"
--FROM dba_users u
--LEFT JOIN dba_role_privs rp
--  ON u.username = rp.grantee
--WHERE u.account_status = 'OPEN' AND u.username LIKE '%ADMIN%'
--ORDER BY u.created DESC;
--
----RUNNING START FROM HERE.
--
--CREATE tech_hunter_db_owner USER
----delete if exists;
SELECT COUNT(*) INTO v_exists
  FROM dba_users
  WHERE username = 'TECH_HUNTER_DB_OWNER';

  IF v_exists > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER tech_hunter_db_owner CASCADE';
  END IF;

----create user;
EXECUTE IMMEDIATE 'CREATE USER tech_hunter_db_owner IDENTIFIED BY db_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA';

---- verify if the user was created right.
SELECT COUNT(*) INTO v_count
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_OWNER';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_OWNER user wasnt created properly.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[4.] The TECH_HUNTER_DB_OWNER was created.');


--SELECT username
--FROM all_users
--WHERE username LIKE '%TECH_HUNTER_DB_OWNER%'
--ORDER BY username;
----TECH_HUNTER_DB_OWNER

----grant the rights for this user;

EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO tech_hunter_db_owner';  -- Permite conectarea
EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO tech_hunter_db_owner';               -- Permite crearea de tabele
EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO tech_hunter_db_owner';              -- Permite crearea de view-uri
EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO tech_hunter_db_owner';           -- Permite crearea de proceduri
EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO tech_hunter_db_owner';            -- Permite crearea de secvente
EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO tech_hunter_db_owner';           -- Permite crearea de trigger-e
EXECUTE IMMEDIATE 'GRANT CREATE SYNONYM TO tech_hunter_db_owner';            -- Permite crearea de sinonime
EXECUTE IMMEDIATE 'GRANT CREATE INDEXTYPE TO tech_hunter_db_owner';           -- Permite crearea de indextypes
EXECUTE IMMEDIATE 'GRANT CREATE OPERATOR TO tech_hunter_db_owner';            -- Permite crearea de operatori
EXECUTE IMMEDIATE 'GRANT CREATE MATERIALIZED VIEW TO tech_hunter_db_owner';   -- Permite crearea de materialized views
EXECUTE IMMEDIATE 'GRANT CREATE TYPE TO tech_hunter_db_owner';                -- Permite crearea de tipuri
---- grant to user the right to administrate his objects
EXECUTE IMMEDIATE 'GRANT ALTER ANY PROCEDURE TO tech_hunter_db_owner';        -- Permite modificarea procedurilor proprii
EXECUTE IMMEDIATE 'GRANT DROP ANY TABLE TO tech_hunter_db_owner';             -- Permite stergerea tabelelor proprii
---- unlock the account if it is blocked
EXECUTE IMMEDIATE 'ALTER USER tech_hunter_db_owner ACCOUNT UNLOCK';

--Drop if exist this role
EXECUTE IMMEDIATE 'DROP ROLE tech_admin_role';
----Vom crea un rol similar cu DBA si anume tech_admin_role
EXECUTE IMMEDIATE 'CREATE ROLE tech_admin_role';
EXECUTE IMMEDIATE 'GRANT CREATE SESSION,CREATE TABLE,CREATE VIEW,CREATE PROCEDURE,CREATE SEQUENCE,CREATE TRIGGER,CREATE USER,ALTER USER,DROP USER,SELECT ANY TABLE,INSERT ANY TABLE,UPDATE ANY TABLE,DELETE ANY TABLE,EXECUTE ANY PROCEDURE TO tech_admin_role';
EXECUTE IMMEDIATE 'GRANT tech_admin_role TO tech_hunter_db_owner';
----and lets see rolurile acestui cont

SELECT
  COUNT(*) INTO v_count
FROM dba_users u
LEFT JOIN dba_role_privs rp
  ON u.username = rp.grantee
WHERE 1 = 1 
AND u.account_status = 'OPEN' 
AND u.username LIKE '%TECH_HUNTER_DB_OWNER%'
AND u.account_status = 'OPEN'
AND rp.granted_role = 'TECH_ADMIN_ROLE'
ORDER BY u.created DESC;

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_OWNER user dont have privilegies.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[5.] The TECH_HUNTER_DB_OWNER has the right privilegies.');


--SELECT
--  u.username               AS "User",
--  u.account_status         AS "Status_Cont",
--  TO_CHAR(u.created, 'DD-MM-YYYY HH24:MI:SS') AS "Creat_la",
--  rp.granted_role          AS "Rol_Atribuit"
--FROM dba_users u
--LEFT JOIN dba_role_privs rp
--  ON u.username = rp.grantee
--WHERE u.account_status = 'OPEN' AND u.username LIKE '%TECH_HUNTER_DB_OWNER%'
--ORDER BY u.created DESC;

--CREATE TECH_HUNTER_DB_OUT_OWNER USER
----delete if exists;
SELECT COUNT(*) INTO v_exists
  FROM dba_users
  WHERE username = 'TECH_HUNTER_DB_OUT_OWNER';

  IF v_exists > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER TECH_HUNTER_DB_OUT_OWNER CASCADE';
  END IF;

----create user;
EXECUTE IMMEDIATE 'CREATE USER tech_hunter_db_out_owner IDENTIFIED BY db_out_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA';

---- verify if the user was created right.
SELECT COUNT(*) INTO v_count
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_OUT_OWNER';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_OUT_OWNER user wasnt created properly.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[6.] The TECH_HUNTER_DB_OUT_OWNER was created.');


--SELECT username
--FROM all_users
--WHERE username LIKE '%TECH_HUNTER_DB_OUT_OWNER%'
--ORDER BY username;
----TECH_HUNTER_DB_OUT_OWNER

----grant the rights for this user;

EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO TECH_HUNTER_DB_OUT_OWNER';  -- Permite conectarea
EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO TECH_HUNTER_DB_OUT_OWNER';               -- Permite crearea de tabele
EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO TECH_HUNTER_DB_OUT_OWNER';              -- Permite crearea de view-uri
EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO TECH_HUNTER_DB_OUT_OWNER';           -- Permite crearea de proceduri
EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO TECH_HUNTER_DB_OUT_OWNER';            -- Permite crearea de secvente
EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO TECH_HUNTER_DB_OUT_OWNER';           -- Permite crearea de trigger-e
EXECUTE IMMEDIATE 'GRANT CREATE SYNONYM TO TECH_HUNTER_DB_OUT_OWNER';            -- Permite crearea de sinonime
EXECUTE IMMEDIATE 'GRANT CREATE INDEXTYPE TO TECH_HUNTER_DB_OUT_OWNER';           -- Permite crearea de indextypes
EXECUTE IMMEDIATE 'GRANT CREATE OPERATOR TO TECH_HUNTER_DB_OUT_OWNER';            -- Permite crearea de operatori
EXECUTE IMMEDIATE 'GRANT CREATE MATERIALIZED VIEW TO TECH_HUNTER_DB_OUT_OWNER';   -- Permite crearea de materialized views
EXECUTE IMMEDIATE 'GRANT CREATE TYPE TO TECH_HUNTER_DB_OUT_OWNER';                -- Permite crearea de tipuri
---- grant to user the right to administrate his objects
EXECUTE IMMEDIATE 'GRANT ALTER ANY PROCEDURE TO TECH_HUNTER_DB_OUT_OWNER';        -- Permite modificarea procedurilor proprii
EXECUTE IMMEDIATE 'GRANT DROP ANY TABLE TO TECH_HUNTER_DB_OUT_OWNER';             -- Permite stergerea tabelelor proprii
---- unlock the account if it is blocked
EXECUTE IMMEDIATE 'ALTER USER TECH_HUNTER_DB_OUT_OWNER ACCOUNT UNLOCK';

--Drop if exist this role
EXECUTE IMMEDIATE 'DROP ROLE tech_admin_role';
----Vom crea un rol similar cu DBA si anume tech_admin_role
EXECUTE IMMEDIATE 'CREATE ROLE tech_admin_role';
EXECUTE IMMEDIATE 'GRANT CREATE SESSION,CREATE TABLE,CREATE VIEW,CREATE PROCEDURE,CREATE SEQUENCE,CREATE TRIGGER,CREATE USER,ALTER USER,DROP USER,SELECT ANY TABLE,INSERT ANY TABLE,UPDATE ANY TABLE,DELETE ANY TABLE,EXECUTE ANY PROCEDURE TO tech_admin_role';
EXECUTE IMMEDIATE 'GRANT tech_admin_role TO TECH_HUNTER_DB_OUT_OWNER';
----and lets see rolurile acestui cont

SELECT
  COUNT(*) INTO v_count
FROM dba_users u
LEFT JOIN dba_role_privs rp
  ON u.username = rp.grantee
WHERE 1 = 1 
AND u.account_status = 'OPEN' 
AND u.username LIKE '%TECH_HUNTER_DB_OUT_OWNER%'
AND u.account_status = 'OPEN'
AND rp.granted_role = 'TECH_ADMIN_ROLE'
ORDER BY u.created DESC;

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_OUT_OWNER user dont have privilegies.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[7.] The TECH_HUNTER_DB_OUT_OWNER has the right privilegies.');


--SELECT
--  u.username               AS "User",
--  u.account_status         AS "Status_Cont",
--  TO_CHAR(u.created, 'DD-MM-YYYY HH24:MI:SS') AS "Creat_la",
--  rp.granted_role          AS "Rol_Atribuit"
--FROM dba_users u
--LEFT JOIN dba_role_privs rp
--  ON u.username = rp.grantee
--WHERE u.account_status = 'OPEN' AND u.username LIKE '%TECH_HUNTER_DB_OUT_OWNER%'
--ORDER BY u.created DESC;
--


  DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
