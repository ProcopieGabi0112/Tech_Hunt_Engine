--AUTONOMOUS_DW_LANDING_OWNER_DWH_COUNTRY_TBL_1_v1.0.0
--"DWH_COUNTRY TABLE"
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

--DELETE TABLE DWH_COUNTRY IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_COUNTRY'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_landing_owner.dw_country CASCADE CONSTRAINTS';
END IF;
--CREATE DWH_COUNTRY TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_landing_owner.dw_country (
          --business columns
          country_id NUMBER(38,0),
          name VARCHAR2(100) NOT NULL,
          code VARCHAR2(30) NOT NULL,
          population NUMBER(15,0) NOT NULL, 
          area NUMBER(10,0) NOT NULL,
          time_zone VARCHAR2(50) NOT NULL, 
          unemployment_rate NUMBER (5,2) NOT NULL, 
          inflation_rate NUMBER (6,2) NOT NULL, 
          average_monthly_salary NUMBER(10,2) NOT NULL, 
          corporate_tax_rate NUMBER (5,2) NOT NULL, 
           
    rating NUMBER(5,2) GENERATED ALWAYS AS (
    ROUND(
        (
            0.30 * GREATEST(1 - (unemployment_rate / 25), 0) +
            0.25 * GREATEST(1 - (inflation_rate / 30), 0) +
            0.30 * LEAST(average_monthly_salary / 10000, 1) +
            0.15 * GREATEST(1 - (corporate_tax_rate / 35), 0)
        ) * 100
    , 2)
) VIRTUAL,


          region_id NUMBER(38,0), 
          official_lang_code NUMBER(38,0), 
          currency_code NUMBER(38,0), 
          
          --technical columns
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')),
          )
    ]';
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_landing_owner.dw_country TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_LANDING_OWNER'
AND table_name = 'DWH_COUNTRY'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_COUNTRY table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_COUNTRY table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_landing_owner.dw_country IS ''This table will contains the information about countries like Romania, Bulgaria, Italia, etc''';

-- BUSINESS COLUMNS
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.country_id IS ''The id of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.name IS ''The name of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.code IS ''The code of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.population IS ''The population of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.area IS ''The area of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.time_zone IS ''The time zone of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.unemployment_rate IS ''The unemployment rate of the country ''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.inflation_rate IS ''The inflation rate of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.average_monthly_salary IS ''The average monthly salary of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.corporate_tax_rate IS ''The corporate tax of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.rating IS ''The rating of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.region_id IS ''The region id of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.official_lang_code IS ''The code of the official language of the country''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.dw_country.currency_code IS ''The currency code of the country''';
--TECHNOCAL COLUMNS
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_landing_owner.skill.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

DBMS_OUTPUT.PUT_LINE('[4.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/