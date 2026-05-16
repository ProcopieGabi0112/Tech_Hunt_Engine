--AUTONOMOUS_DW_OUT_OWNER_DWH_SPECIALIZATION_DIM_V_VW_1_v1.0.0
--"DWH_SPECIALIZATION_DIM_V TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DW_OUT_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_OUT_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDW"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE dwh_specialization_dim IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DW_OUT_OWNER'
AND view_name = 'DWH_SPECIALIZATION_DIM_V';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP VIEW autonomous_dw_out_owner.dwh_specialization_dim_v CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_SPECIALIZATION_DIM_V TABLE;
v_sql := q'[
CREATE OR REPLACE VIEW autonomous_dw_out_owner.dwh_specialization_dim_v AS
SELECT 
specialization_key,
institution_specialization_code,
specialization_name,
specialization_rating,
specialization_type_name,
specialization_score,
institution_name,
institution_details,
institution_rating,
overall_specialization_rating,
institution_location_key,
creation_date,
created_by,
last_update_date,
last_updated_by,
valid_from,
valid_to,
source_system,
deleted_flag
FROM autonomous_dw_owner.dwh_specialization_dim;
]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
AND view_name = 'DWH_SPECIALIZATION_DIM_V';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_SPECIALIZATION_DIM_V view wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_SPECIALIZATION_DIM_V view was created.');

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/