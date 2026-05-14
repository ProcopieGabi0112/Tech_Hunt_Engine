--AUTONOMOUS_DW_LANDING_OWNER_DWH_COMPANY_TBL_1_v1.0.0
--"DWH_COMPANY TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DW_LANDING_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_LANDING_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE company IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_COMPANY'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_landing_owner.dwh_company CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_COMPANY TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_landing_owner.dwh_company (

          --business columns
          company_id NUMBER(38,0)NOT NULL,
          legal_entity_identifier VARCHAR2(50) NOT NULL,
          name VARCHAR2(255) NOT NULL,
          trade_register_number VARCHAR2(50) NOT NULL,
          website VARCHAR2(255) NOT NULL,
          foundation_date DATE NOT NULL,
          no_employees NUMBER(15,0) NOT NULL, 
          description VARCHAR2(200) NOT NULL,
          sign_image BLOB,
          profile_image BLOB,
          share_capital NUMBER(15,2) NOT NULL,
          net_profit NUMBER(15,0) NOT NULL,
          average_annual_revenue NUMBER(15,0) NOT NULL,
          total_assets NUMBER(15,0) NOT NULL,
          total_liabilities NUMBER(15,0) NOT NULL,
          debt_to_equity_ratio NUMBER(15,0) NOT NULL,
          rating NUMBER(5,2),
          user_id NUMBER(38,0) NOT NULL,
          user_email VARCHAR2(70) NOT NULL, 
          industry_type_id NUMBER(25,0) NOT NULL, 
          company_type_id NUMBER(25,0) NOT NULL,
          company_location_id NUMBER(38,0) NOT NULL,
          currency_code NUMBER(38,0) NOT NULL,
          
          --technical columns
          creation_date         TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          sync_status           VARCHAR2(20) NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) NOT NULL,
          last_synced_at        TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(1) NOT NULL CHECK (deleted_flag IN ('N','Y')), 
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_landing_owner.dwh_company TO autonomous_dw_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_COMPANY'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_COMPANY table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The DWH_COMPANY table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_landing_owner.dwh_company IS ''The table contains all the informations about the companies from application. Some posibile values like BCR,Thales, Ubisoft,etc''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.company_id IS ''The id of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.legal_entity_identifier IS ''The id of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.name IS ''The name of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.trade_register_number IS ''The trade register number of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.website IS ''The website of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.foundation_date IS ''The foundation date of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.no_employees IS ''The number of employees of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.description IS ''The description of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.sign_image IS ''The sign image of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.profile_image IS ''The profile image of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.share_capital IS ''The share capital of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.net_profit IS ''The net profit of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.average_annual_revenue IS ''The average annual revenue of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.total_assets IS ''The total assets of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.total_liabilities IS ''The total liabilities of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.debt_to_equity_ratio IS ''The debt to equity of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.rating IS ''The rating of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.user_id IS ''The id of the user who register the company into the application''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.user_email IS ''The email the user who register the company into the application''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.industry_type_id IS ''The industry type id of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.company_type_id IS ''The company type id of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.company_location_id IS ''The company location id of the company''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.currency_code IS ''The currency code of the values used to resolve the rating value''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dwh_company.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/