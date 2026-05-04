--AUTONOMOUS_DB_OUT_OWNER_REVIEW_V_VW_1_v1.0.0
--"REVIEW_V VIEW"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DB_OUT_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DB_OUT_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE REVIEW_V IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
AND view_name = 'REVIEW_V';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP VIEW autonomous_db_out_owner.review_v CASCADE CONSTRAINTS';
END IF;
--CREATE REVIEW_V TABLE;
v_sql := q'[
CREATE OR REPLACE VIEW autonomous_db_out_owner.review_v AS
SELECT 
review_id,
title, 
review_type,
description,
rating_overall,
work_rating,
salary_rating,
manager_rating,
team_rating,
would_recommend,
is_annonymous,
is_verified,
job_id,
user_id,
job_history_id,
application_id,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM autonomous_db_owner.review;
]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
AND view_name = 'REVIEW_V';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The REVIEW_V view wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The REVIEW_V view was created.');

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/