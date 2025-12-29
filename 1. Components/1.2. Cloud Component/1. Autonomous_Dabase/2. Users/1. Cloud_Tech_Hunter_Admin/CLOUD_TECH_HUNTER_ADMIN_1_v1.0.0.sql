--CLOUD_TECH_HUNTER_ADMIN_1_v1.0.0
--"MAIN USERS FROM CLOUD DATABASE"
SET SERVEROUTPUT ON;
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
-- Current_User: "ADMIN"	
-- Database_name: "FCEN3PO9"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--[2.] CHECK CDB_DATABASE STATUS
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
-- Pluggable_Database_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Status: "NORMAL"
-- Database_Open_Mode: "READ WRITE"
-- Open Time: "2025-10-08 15:57:09"

----The script running from here...

--CREATE TECH_ADMIN_ROLE;
--DROP IF EXITS THIS ROLE
EXECUTE IMMEDIATE 'DROP ROLE tech_admin_role';
--CREATE TECH_ADMIN_ROLE
EXECUTE IMMEDIATE 'CREATE ROLE tech_admin_role';
EXECUTE IMMEDIATE 'GRANT CREATE SESSION,
                         CREATE TABLE,
                         CREATE VIEW,
                         CREATE PROCEDURE,
                         CREATE SEQUENCE,
                         CREATE TRIGGER,
                         CREATE SYNONYM,
                         CREATE INDEXTYPE,
                         CREATE OPERATOR,
                         CREATE MATERIALIZED VIEW,
                         CREATE TYPE,
                         CREATE DATABASE LINK,
                         ALTER ANY PROCEDURE,
                         CREATE ANY TABLE,
                         CREATE ANY VIEW,
                         CREATE ANY PROCEDURE,
                         CREATE ANY SEQUENCE,
                         CREATE ANY TRIGGER,
                         CREATE ANY SYNONYM,
                         CREATE ANY MATERIALIZED VIEW,
                         CREATE ANY TYPE,
                         CREATE ANY INDEXTYPE,
                         CREATE ANY OPERATOR,
                         DROP ANY PROCEDURE,
                         ALTER ANY TRIGGER,
                         DROP ANY TRIGGER,
                         DROP ANY TABLE,
                         ALTER ANY MATERIALIZED VIEW,
                         DROP ANY MATERIALIZED VIEW,
                         DROP ANY SYNONYM,
                         ALTER ANY SEQUENCE,
                         DROP ANY SEQUENCE,
                         SELECT ANY TABLE,
                         INSERT ANY TABLE,
                         UPDATE ANY TABLE,
                         DELETE ANY TABLE,
                         EXECUTE ANY PROCEDURE 
                    TO tech_admin_role';

--CREATE TECH_HUNT_DB_OWNER USER (PRODUCTION_SCHEMA)
--DELETE USER IF EXIST;
SELECT COUNT(*) INTO v_exists
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_OWNER';
IF v_exists > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER tech_hunter_db_owner CASCADE';
END IF;
--CREATE TECH_HUNT_DB_OWNER USER;
EXECUTE IMMEDIATE 'CREATE USER tech_hunter_db_owner IDENTIFIED BY db_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA';
--UNLOCK THE ACCOUNT IF IT IS BLOCKED
EXECUTE IMMEDIATE 'ALTER USER tech_hunter_db_owner ACCOUNT UNLOCK';
-- VERIFY IF THE USER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_OWNER';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_OWNER user wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TECH_HUNTER_DB_OWNER was created.');
--GRANT THE TECH_ADMIN_ROLE TO TECH_HUNTER_DB_OWNER
EXECUTE IMMEDIATE 'GRANT tech_admin_role TO tech_hunter_db_owner';

--[5.] VERIFY IF THE USER TECH_hUNTER_DB_OWNER HAVE THE RIGHT PRIVILEGIES
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

--CREATE TECH_HUNT_DB_OUT_OWNER USER (PRODUCTION_EXPOSURE_SCHEMA)
--DELETE USER IF EXIST;
SELECT COUNT(*) INTO v_exists
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_OUT_OWNER';
IF v_exists > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER TECH_HUNTER_DB_OUT_OWNER CASCADE';
END IF;
--CREATE TECH_HUNT_DB_OWNER USER;
EXECUTE IMMEDIATE 'CREATE USER TECH_HUNTER_DB_OUT_OWNER IDENTIFIED BY db_out_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA';
--UNLOCK THE ACCOUNT IF IT IS BLOCKED
EXECUTE IMMEDIATE 'ALTER USER TECH_HUNTER_DB_OUT_OWNER ACCOUNT UNLOCK';
-- VERIFY IF THE USER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_OUT_OWNER';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_OUT_OWNER user wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TECH_HUNTER_DB_OUT_OWNER was created.');
--GRANT THE TECH_ADMIN_ROLE TO TECH_HUNTER_DB_OUT_OWNER
EXECUTE IMMEDIATE 'GRANT tech_admin_role TO TECH_HUNTER_DB_OUT_OWNER';

--[5.] VERIFY IF THE USER TECH_HUNTER_DB_OUT_OWNER HAVE THE RIGHT PRIVILEGIES
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

--CREATE TECH_HUNT_DB_OUT_OWNER USER (DEVELOPMENT_SCHEMA)
--DELETE USER IF EXIST;
SELECT COUNT(*) INTO v_exists
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_TST_OWNER';
IF v_exists > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER TECH_HUNTER_DB_TST_OWNER CASCADE';
END IF;
--CREATE TECH_HUNT_DB_TST_OWNER USER;
EXECUTE IMMEDIATE 'CREATE USER TECH_HUNTER_DB_TST_OWNER IDENTIFIED BY db_tst_owner_Pass011297
DEFAULT TABLESPACE SAMPLESCHEMA
QUOTA UNLIMITED ON SAMPLESCHEMA';
--UNLOCK THE ACCOUNT IF IT IS BLOCKED
EXECUTE IMMEDIATE 'ALTER USER TECH_HUNTER_DB_TST_OWNER ACCOUNT UNLOCK';
-- VERIFY IF THE USER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM dba_users
WHERE username = 'TECH_HUNTER_DB_TST_OWNER';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_TST_OWNER user wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[8.] The TECH_HUNTER_DB_TST_OWNER was created.');
--GRANT THE TECH_ADMIN_ROLE TO TECH_HUNTER_DB_TST_OWNER
EXECUTE IMMEDIATE 'GRANT tech_admin_role TO TECH_HUNTER_DB_TST_OWNER';

--[5.] VERIFY IF THE USER TECH_HUNTER_DB_TST_OWNER HAVE THE RIGHT PRIVILEGIES
SELECT
  COUNT(*) INTO v_count
FROM dba_users u
LEFT JOIN dba_role_privs rp
  ON u.username = rp.grantee
WHERE 1 = 1 
AND u.account_status = 'OPEN' 
AND u.username LIKE '%TECH_HUNTER_DB_TST_OWNER%'
AND u.account_status = 'OPEN'
AND rp.granted_role = 'TECH_ADMIN_ROLE'
ORDER BY u.created DESC;
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TECH_HUNTER_DB_TST_OWNER user dont have privilegies.');
END IF;
DBMS_OUTPUT.PUT_LINE('[9.] The TECH_HUNTER_DB_TST_OWNER has the right privilegies.');




  DBMS_OUTPUT.PUT_LINE('[10.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
