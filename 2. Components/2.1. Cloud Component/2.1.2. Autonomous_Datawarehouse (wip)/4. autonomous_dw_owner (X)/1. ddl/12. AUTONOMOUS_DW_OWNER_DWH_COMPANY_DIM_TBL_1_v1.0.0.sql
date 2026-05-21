--AUTONOMOUS_DW_OWNER_DWH_COMPANY_DIM_TBL_1_v1.0.0
--"DWH_COMPANY_DIM TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DW_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE specialization_type IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_COMPANY_DIM'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_owner.dwh_company_dim CASCADE CONSTRAINTS';
END IF;


--CREATE UTILIZATORI TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_owner.dwh_company_dim (

          --business columns
          company_key NUMBER(38,0) PRIMARY KEY,
          company_id NUMBER(38,0) NOT NULL,
          company_identifier VARCHAR2(200) NOT NULL,
          company_name VARCHAR2(255) NOT NULL,
          company_website VARCHAR2(4000) NOT NULL,
          foundation_date DATE NOT NULL,
          share_capital NUMBER(15,2) NOT NULL,
          net_profit NUMBER(15,0) NOT NULL,
          average_annual_revenue NUMBER(15,0) NOT NULL,
          total_assets NUMBER(15,0) NOT NULL,
          total_liabilities NUMBER(15,0) NOT NULL,
          debt_to_equity_ratio NUMBER(15,0) NOT NULL,
          no_employees NUMBER(15,0) NOT NULL,
          company_age_years NUMBER(4,0) NOT NULL,
          profit_margin NUMBER(10,4) GENERATED ALWAYS AS (
                CASE WHEN average_annual_revenue = 0 THEN 0
                     ELSE ROUND(net_profit / average_annual_revenue, 4)
                END
          ) STORED,
          revenue_per_employee NUMBER(15,4) GENERATED ALWAYS AS (
                CASE WHEN no_employees = 0 THEN 0
                     ELSE ROUND(average_annual_revenue / no_employees, 4)
                END
          ) STORED,
          financial_health_score NUMBER(10,4) GENERATED ALWAYS AS (
                   CASE WHEN total_assets = 0 THEN 0
                        ELSE ROUND((net_profit + average_annual_revenue) / total_assets, 4)
                   END
           ) STORED,
          leverage_ratio NUMBER(10,4) GENERATED ALWAYS AS (
                  CASE WHEN total_liabilities = 0 THEN NULL
                       ELSE ROUND(total_assets / total_liabilities, 4)
                  END
          ) STORED,
          org_health_score NUMBER(10,4) GENERATED ALWAYS AS (
                    ROUND(
                          (average_departments_rating * 0.4) +
                          ((1 - (average_turnover_rate / 100)) * 0.3) +
                          (total_open_positions * 0.3)
                        ,4)
          ) STORED,

          org_stability_score NUMBER(10,4) GENERATED ALWAYS AS (
                       ROUND(1 - (average_turnover_rate / 100), 4)
          ) STORED,
          company_rating NUMBER(5,2) NOT NULL,
          departments_with_open_positions NUMBER(15,0) NOT NULL,
          total_open_positions NUMBER(15,0) NOT NULL,
          average_departments_rating NUMBER(5,2) NOT NULL,
          average_turnover_rate NUMBER(10,4) NOT NULL,
          total_departments_budget NUMBER(15,0) NOT NULL,
          total_departments_expenses NUMBER(15,0) NOT NULL,
          company_type_id NUMBER(25,0) NOT NULL,
          company_type_name VARCHAR2(100) NOT NULL,
          industry_type_id NUMBER(25,0) NOT NULL,
          industry_type_name VARCHAR2(100) NOT NULL,
          company_location_key NUMBER(38,0) NOT NULL,

          --technical columns
          creation_date         TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          valid_from            TIMESTAMP NOT NULL,
          valid_to              TIMESTAMP NOT NULL,
          source_system         VARCHAR2(20) NOT NULL CHECK (source_system IN ('db_env')),
          deleted_flag          VARCHAR2(1) NOT NULL CHECK (deleted_flag IN ('N','Y')),
          CONSTRAINT fk_company_dim_location
          FOREIGN KEY (company_location_key)
          REFERENCES autonomous_dw_owner.dwh_company_location_dim (company_location_key)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_owner.dwh_company_dim TO autonomous_dw_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_COMPANY_DIM'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_COMPANY_DIM table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_COMPANY_DIM table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_owner.dwh_company_dim IS ''Dimension table containing enriched company information with financial, organizational and ML-ready metrics.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_key IS ''Surrogate key of the company dimension.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_id IS ''Natural key of the company from the source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_name IS ''Official name of the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_website IS ''Official website of the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.foundation_date IS ''The date when the company was founded.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.share_capital IS ''Declared share capital of the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.net_profit IS ''Net profit reported by the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.average_annual_revenue IS ''Average annual revenue generated by the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.total_assets IS ''Total assets owned by the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.total_liabilities IS ''Total liabilities of the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.debt_to_equity_ratio IS ''Financial ratio measuring leverage (debt-to-equity).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.no_employees IS ''Total number of employees working in the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_age_years IS ''Derived metric: age of the company in years.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.profit_margin IS ''Derived metric: net profit divided by annual revenue.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.revenue_per_employee IS ''Derived metric: annual revenue divided by number of employees.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.financial_health_score IS ''Derived metric: synthetic score combining profitability and asset strength.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.leverage_ratio IS ''Derived metric: assets divided by liabilities.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.org_health_score IS ''Derived metric: organizational health score based on department performance.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.org_stability_score IS ''Derived metric: organizational stability score based on turnover and structure.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_rating IS ''Overall rating of the company from the source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.departments_with_open_positions IS ''Number of departments that currently have open job positions.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.total_open_positions IS ''Total number of open job positions across all departments.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.average_departments_rating IS ''Average rating of all departments belonging to the company.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.average_turnover_rate IS ''Average turnover rate across all departments.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.total_departments_budget IS ''Total annual budget allocated to all departments.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.total_departments_expenses IS ''Total expenses reported by all departments.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_type_id IS ''Natural key referencing the company type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_type_name IS ''The name of the company type (e.g., SRL, SA).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.industry_type_id IS ''Natural key referencing the industry type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.industry_type_name IS ''The name of the industry type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.company_location_key IS ''Foreign key referencing the company location dimension.''';
-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.valid_from IS ''Technical Column - The timestamp indicating when the record becomes effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.valid_to IS ''Technical Column - The timestamp indicating when the record stops being effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_company_dim.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_TECHNOLOGY_TYPE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_COMPANY_KEY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_dw_owner.seq_company_key';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_company_key
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_COMPANY_KEY';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_COMPANY_KEY sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_COMPANY_KEY sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_COMPANY_KEY_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_company_key_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_company_key_pk
          BEFORE INSERT ON autonomous_dw_owner.dwh_company_dim
          FOR EACH ROW
          WHEN (NEW.company_key IS NULL)
          BEGIN
             SELECT seq_company_key.NEXTVAL INTO :NEW.company_key FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_COMPANY_KEY_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_COMPANY_KEY_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_COMPANY_KEY_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_COMPANY_DIM_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_company_dim_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_dwh_company_dim_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_company_dim
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
        -- creation metadata
        :NEW.creation_date := CURRENT_TIMESTAMP;
        :NEW.created_by := ''ETL_COMPANY_DAILY_PROCESS'';

        -- update metadata
        :NEW.last_update_date := :NEW.creation_date;
        :NEW.last_updated_by := ''ETL_COMPANY_DAILY_PROCESS'';

        -- validity (SCD1 → no history)
        :NEW.valid_from := CURRENT_TIMESTAMP;
        :NEW.valid_to := TO_TIMESTAMP(''9999-12-31 23:59:59'', ''YYYY-MM-DD HH24:MI:SS'');

        -- source system
        IF :NEW.source_system IS NULL THEN
            :NEW.source_system := ''db_env'';
        END IF;

        -- deleted flag
        IF :NEW.deleted_flag IS NULL THEN
            :NEW.deleted_flag := ''N'';
        END IF;
    END IF;

    IF UPDATING THEN
        -- update metadata
        :NEW.last_update_date := CURRENT_TIMESTAMP;
        :NEW.last_updated_by := ''ETL_COMPANY_DAILY_PROCESS'';

    END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_COMPANY_DIM_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_COMPANY_DIM_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_DWH_COMPANY_DIM_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR POPULATING job_version_age COLUMN
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_COMPANY_DIM_AGE_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_company_dim_age_sync';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_company_dim_age_sync
BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_company_dim
FOR EACH ROW
BEGIN
    --------------------------------------------------------------------
    -- COMPANY AGE (în ani)
    -- Calculat pe baza foundation_date și CURRENT_DATE
    --------------------------------------------------------------------
    IF :NEW.foundation_date IS NOT NULL THEN
        :NEW.company_age_years :=
            EXTRACT(YEAR FROM CURRENT_DATE) -
            EXTRACT(YEAR FROM :NEW.foundation_date);
    ELSE
        :NEW.company_age_years := NULL;
    END IF;

END;
';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_COMPANY_DIM_AGE_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_COMPANY_DIM_AGE_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_COMPANY_DIM_AGE_SYNC trigger for populating version_age column was created.');

DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/