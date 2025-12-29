--RUNS INTO ADMIN SCHEMA ON CLOUD DATABASE
--[1.] CHECK CURRENT USER AND SCHEMA
SELECT sys_context('USERENV', 'SESSION_USER') AS current_user,
       name AS database_name,
       sys_context('USERENV', 'CON_NAME') AS current_container,
       CASE 
           WHEN cdb = 'YES' AND sys_context('USERENV', 'CON_NAME') = 'CDB$ROOT' 
           THEN 'Container Database (CDB)' 
           ELSE 'Pluggable Database (PDB)' 
       END AS database_type
FROM v$database;
-- Current_User: "ADMIN"	
-- Database_name: "FCEN3PO9"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"
--[2.] CHECK CDB_DATABASE STATUS
SELECT name db_name,
             open_mode state,
             status db_status,
             cdb final_status 
FROM v$database,v$instance;
-- Database_Name: "FCEN3PO9"	
-- Database_State: "READ WRITE"
-- Database_Status: "OPEN"
-- Database_Final_Status: "YES"
--[3.] CHECK PDB_DATABASE STATUS
SELECT c.pdb_id no,
             c.pdb_name pluggable_db_name,
             c.status status,
             v.open_mode open_mode,
             TO_CHAR(v.open_time,'yyyy-mm-dd HH24:MI:SS') AS open_time 
FROM v$pdbs v 
INNER JOIN cdb_pdbs c 
ON v.name = c.pdb_name;
-- Pluggable_Database_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Status: "NORMAL"
-- Database_Open_Mode: "READ WRITE"
-- Open Time: "2025-10-08 15:57:09"
--[4.] CHECK DATABASE TABLESPACE
SELECT 
       --f.con_id||'/'||f.file_id||'/'||v.file# con_file_id,
       f.tablespace_name,
       --f.file_name,
       ROUND(f.bytes / 1024 / 1024, 2) AS size_mb,
       ROUND(f.bytes / 1024 / 1024 / 1024, 2) AS size_gb,
       --p.pdb_name,
       f.status ||' - '|| v.status ||' - '||v.enabled as status
FROM   cdb_data_files f
FULL JOIN   cdb_pdbs p ON f.con_id = p.con_id
FULL JOIN   v$datafile v ON f.file_id = v.file#
ORDER BY f.con_id;
-- TABLESPACE_NAME  SIZE_MB   SIZE_GB   STATUS
-- SYSTEM	     	1281	  1.25		AVAILABLE - SYSTEM - READ WRITE
-- SYSAUX	     	2090	  2.04		AVAILABLE - ONLINE - READ WRITE
-- SAMPLESCHEMA		204800	  200	    AVAILABLE - ONLINE - READ ONLY
-- DATA	        	1124	  1.17   	AVAILABLE - ONLINE - READ WRITE
-- DBFS_DATA		100	      0.1		AVAILABLE - ONLINE - READ WRITE
-- UNDOTBS1	     	1635	  1.6		AVAILABLE - ONLINE - READ WRITE
--[5.] VERIFY ACTIVE USERS
SELECT 
username AS USER_NAME,
status AS USER_STATUS,
osuser AS windows_user_name,
machine AS windows_machine_name,
program AS tool,
TO_CHAR(logon_time, 'yyyy-mm-dd HH24:MI:SS') AS session_start_at,
TO_CHAR(sql_exec_start, 'yyyy-mm-dd HH24:MI:SS') AS sql_start_at,
TO_CHAR(prev_exec_start, 'yyyy-mm-dd HH24:MI:SS') AS last_session_start_at
FROM V$SESSION
WHERE username <> 'OML$METADATA';
-- USER_NAME: "ADMIN"	
-- USER_STATUS: "ACTIVE"	
-- WINDOWS_USER_NAME: "dproc"	
-- WINDOWS_MACHINE_NAME: "DESKTOP-POD05B4"	
-- TOOL_CONECTARE: "SQL Developer"	
-- Data_conectare:   "2025-10-08 19:59:14"	
-- Data_rulare_sql:  "2025-10-08 20:29:48"	
-- Ultima_conectare: "2025-10-08 20:29:34"
--[6.] VERIFY ALL SQL COMMANDS THAT RUNS IN THE LAST TWO HOURS
SELECT
  parsing_schema_name            AS "Schema",
  executions                     AS "Nr_Executii",
  ROUND(elapsed_time / 1000000, 2) AS "Timp_Total_Secunde",
  ROUND(cpu_time / 1000000, 2) AS "Timp_CPU_Secunde",
  disk_reads                     AS "Citiri_Disc",
  buffer_gets                    AS "Citiri_Buffer",
  rows_processed                 AS "Randuri_Procesate",
  parse_calls                    AS "Nr_Parsari",
  ROUND(sharable_mem / 1024, 2)  AS "Memorie_Shareble_KB",
  ROUND(persistent_mem / 1024, 2) AS "Memorie_Persistenta_KB",
  action                         AS "Actiune",
  sql_text                       AS "Text_SQL",
  REPLACE(FIRST_LOAD_TIME,'/',' ') AS "Incarcat_la" ,
  REPLACE(LAST_ACTIVE_TIME,'/',' ') AS "Ultima_activitate",
  ROUND(elapsed_time / 1000000, 2) AS "Timp_total_secunde",
  ROUND(cpu_time / 1000000, 2) AS "Timp_CPU_secunde"
  FROM v$sql
WHERE executions > 0 
AND parsing_schema_name = 'ADMIN' 
AND LAST_ACTIVE_TIME >= SYSDATE - INTERVAL '2' HOUR
ORDER BY elapsed_time DESC
FETCH FIRST 150 ROWS ONLY;
--[7.] VERIFY ALL USERS
SELECT username
FROM all_users
WHERE username IN ('ADMIN')
ORDER BY username;
--[8.] AND ALL THE PRIVILEGIES 
SELECT
  u.username               AS "User",
  u.account_status         AS "Status_Cont",
  TO_CHAR(u.created, 'DD-MM-YYYY HH24:MI:SS') AS "Creat_la",
  rp.granted_role          AS "Rol_Atribuit"
FROM dba_users u
LEFT JOIN dba_role_privs rp
  ON u.username = rp.grantee
WHERE u.account_status = 'OPEN' AND u.username LIKE '%ADMIN%'
ORDER BY u.created DESC;

--RUNNING START FROM HERE.

--CREATE tech_hunter_db_owner USER
--delete if exists;
DROP USER tech_hunter_db_owner CASCADE;
--create user;
CREATE USER tech_hunter_db_owner IDENTIFIED BY db_out_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA;
-- verify if the user was created right.
SELECT username
FROM all_users
WHERE username LIKE '%TECH_HUNTER_DB_OWNER%'
ORDER BY username;
--TECH_HUNTER_DB_OWNER

--grant the rights for this user;
GRANT CREATE SESSION TO tech_hunter_db_owner;             -- Permite conectarea
GRANT CREATE TABLE TO tech_hunter_db_owner;               -- Permite crearea de tabele
GRANT CREATE VIEW TO tech_hunter_db_owner;                -- Permite crearea de view-uri
GRANT CREATE PROCEDURE TO tech_hunter_db_owner;           -- Permite crearea de proceduri
GRANT CREATE SEQUENCE TO tech_hunter_db_owner;            -- Permite crearea de secvente
GRANT CREATE TRIGGER TO tech_hunter_db_owner;             -- Permite crearea de trigger-e
GRANT CREATE SYNONYM TO tech_hunter_db_owner;             -- Permite crearea de sinonime
GRANT CREATE INDEXTYPE TO tech_hunter_db_owner;           -- Permite crearea de indextypes
GRANT CREATE OPERATOR TO tech_hunter_db_owner;            -- Permite crearea de operatori
GRANT CREATE MATERIALIZED VIEW TO tech_hunter_db_owner;   -- Permite crearea de materialized views
GRANT CREATE TYPE TO tech_hunter_db_owner;                -- Permite crearea de tipuri
-- grant to user the right to administrate his objects
GRANT ALTER ANY PROCEDURE TO tech_hunter_db_owner;        -- Permite modificarea procedurilor proprii
GRANT DROP ANY TABLE TO tech_hunter_db_owner;             -- Permite stergerea tabelelor proprii
-- unlock the account if it is blocked
ALTER USER tech_hunter_db_owner ACCOUNT UNLOCK;

--Vom crea un rol similar cu DBA si anume tech_admin_role
CREATE ROLE tech_admin_role;
GRANT
  CREATE SESSION,
  CREATE TABLE,
  CREATE VIEW,
  CREATE PROCEDURE,
  CREATE SEQUENCE,
  CREATE TRIGGER,
  CREATE USER,
  ALTER USER,
  DROP USER,
  SELECT ANY TABLE,
  INSERT ANY TABLE,
  UPDATE ANY TABLE,
  DELETE ANY TABLE,
  EXECUTE ANY PROCEDURE
TO tech_admin_role;
GRANT tech_admin_role TO tech_hunter_db_owner;
--and lets see rolurile acestui cont
SELECT
  u.username               AS "User",
  u.account_status         AS "Status_Cont",
  TO_CHAR(u.created, 'DD-MM-YYYY HH24:MI:SS') AS "Creat_la",
  rp.granted_role          AS "Rol_Atribuit"
FROM dba_users u
LEFT JOIN dba_role_privs rp
  ON u.username = rp.grantee
WHERE u.account_status = 'OPEN' AND u.username LIKE '%TECH_HUNTER_DB_OWNER%'
ORDER BY u.created DESC;

--CREATE tech_hunter_db_out_owner USER
--delete if exists;
DROP USER tech_hunter_db_out_owner CASCADE;
--create user;
CREATE USER tech_hunter_db_out_owner IDENTIFIED BY db_out_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA;
-- verify if the user was created right.
SELECT username
FROM all_users
WHERE username LIKE '%TECH_HUNTER_DB_OUT_OWNER%'
ORDER BY username;
--tech_hunter_db_out_owner

--grant the rights for this user;
GRANT CREATE SESSION TO tech_hunter_db_out_owner;             -- Permite conectarea
GRANT CREATE TABLE TO tech_hunter_db_out_owner;               -- Permite crearea de tabele
GRANT CREATE VIEW TO tech_hunter_db_out_owner;                -- Permite crearea de view-uri
GRANT CREATE PROCEDURE TO tech_hunter_db_out_owner;           -- Permite crearea de proceduri
GRANT CREATE SEQUENCE TO tech_hunter_db_out_owner;            -- Permite crearea de secvente
GRANT CREATE TRIGGER TO tech_hunter_db_out_owner;             -- Permite crearea de trigger-e
GRANT CREATE SYNONYM TO tech_hunter_db_out_owner;             -- Permite crearea de sinonime
GRANT CREATE INDEXTYPE TO tech_hunter_db_out_owner;           -- Permite crearea de indextypes
GRANT CREATE OPERATOR TO tech_hunter_db_out_owner;            -- Permite crearea de operatori
GRANT CREATE MATERIALIZED VIEW TO tech_hunter_db_out_owner;   -- Permite crearea de materialized views
GRANT CREATE TYPE TO tech_hunter_db_out_owner;                -- Permite crearea de tipuri
-- grant to user the right to administrate his objects
GRANT ALTER ANY PROCEDURE TO tech_hunter_db_out_owner;        -- Permite modificarea procedurilor proprii
GRANT DROP ANY TABLE TO tech_hunter_db_out_owner;             -- Permite stergerea tabelelor proprii
-- unlock the account if it is blocked
ALTER USER tech_hunter_db_out_owner ACCOUNT UNLOCK;

--ii vom acorda si lui rolul tech_admin_role
GRANT tech_admin_role TO tech_hunter_db_out_owner;
--and lets see rolurile acestui cont
SELECT
  u.username               AS "User",
  u.account_status         AS "Status_Cont",
  TO_CHAR(u.created, 'DD-MM-YYYY HH24:MI:SS') AS "Creat_la",
  rp.granted_role          AS "Rol_Atribuit"
FROM dba_users u
LEFT JOIN dba_role_privs rp
  ON u.username = rp.grantee
WHERE u.account_status = 'OPEN' AND u.username LIKE '%TECH_HUNTER_DB_OUT_OWNER%'
ORDER BY u.created DESC;
COMMIT;
