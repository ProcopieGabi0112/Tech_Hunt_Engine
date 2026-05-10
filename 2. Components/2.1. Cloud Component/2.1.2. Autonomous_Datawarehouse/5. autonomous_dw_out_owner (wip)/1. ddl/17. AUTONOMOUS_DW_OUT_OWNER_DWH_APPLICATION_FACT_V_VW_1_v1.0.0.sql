--AUTONOMOUS_DW_OUT_OWNER_DWH_APPLICATION_FACT_V_VW_1_v1.0.0
--"DWH_APPLICATION_FACT_V TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--[1.] CHECK CURRENT JOB AND SCHEMA
SELECT COUNT(*) INTO v_count
FROM dual
WHERE sys_context('JOBENV', 'SESSION_JOB') = 'AUTONOMOUS_DW_OUT_OWNER'
AND sys_context('JOBENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('JOBENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the job.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_OUT_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDW"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE dwh_skill_bridge IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DW_OUT_OWNER'
AND view_name = 'DWH_APPLICATION_FACT_V';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP VIEW autonomous_dw_out_owner.dwh_application_fact_v CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_SKILL_BRIDGE_V TABLE;
v_sql := q'[
CREATE OR REPLACE VIEW autonomous_dw_out_owner.dwh_application_fact_v AS
SELECT 
application_fact_key,
application_key,
user_key,
job_key,
date_key,
salary,
application_status,
match_score,
creation_date,
created_by,
last_update_date,
last_updated_by,
valid_from,
valid_to,
source_system,
deleted_flag
FROM autonomous_dw_owner.dwh_application_fact;
]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
AND view_name = 'DWH_APPLICATION_FACT_V';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_APPLICATION_FACT_V view wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_APPLICATION_FACT_V view was created.');

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/