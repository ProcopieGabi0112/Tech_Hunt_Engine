--AUTONOMOUS_DB_OUT_OWNER_COMPANY_V_VW_1_v1.0.0
--"COMPANY_V VIEW"
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

--DELETE TABLE company_v IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
AND view_name = 'COMPANY_V';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP VIEW autonomous_db_out_owner.company_v CASCADE CONSTRAINTS';
END IF;
--CREATE company_v TABLE;
v_sql := q'[
CREATE OR REPLACE VIEW autonomous_db_out_owner.company_v AS
SELECT 
company_id,
legal_entity_identifier,
name,
trade_register_number,
website,
foundation_date,
no_employees,
description,
sign_image,
profile_image,
share_capital,
net_profit,
average_annual_revenue,
total_assets,
total_liabilities,
debt_to_equity_ratio,
rating,
user_id,
user_email,
industry_type_id,
company_type_id,
company_location_id,
currency_code,
creation_date,
created_by,
last_update_date,
last_updated_by,
source_system,
sync_status,
sync_version,
last_synced_at,
deleted_flag
FROM autonomous_db_owner.company;
]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_views
WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
AND view_name = 'COMPANY_v';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The COMPANY_v view wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The COMPANY_v view was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/