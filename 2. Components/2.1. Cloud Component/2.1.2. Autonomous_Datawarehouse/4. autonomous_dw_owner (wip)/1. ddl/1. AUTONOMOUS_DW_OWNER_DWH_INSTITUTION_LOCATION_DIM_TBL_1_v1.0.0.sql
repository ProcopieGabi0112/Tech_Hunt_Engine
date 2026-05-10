--AUTONOMOUS_DW_OWNER_DWH_INSTITUTION_LOCATION_DIM_TBL_1_v1.0.0
--"DWH_INSTITUTION_LOCATION_DIM TABLE"
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
AND table_name = 'DWH_INSTITUTION_LOCATION_DIM'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_owner.dwh_institution_location_dim CASCADE CONSTRAINTS';
END IF;
--CREATE UTILIZATORI TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_owner.dwh_institution_location_dim (

          --business columns
          institution_location_key NUMBER(38,0) PRIMARY KEY,
          location_address_code VARCHAR2(200) NOT NULL,
          location_address VARCHAR2(500) NOT NULL,
          postal_code VARCHAR2(20) NOT NULL,
          location_details VARCHAR2(200),
          city_name VARCHAR2(100) NOT NULL,
          capital_city_flag VARCHAR2(1) NOT NULL CHECK (capital_city_flag IN ('Y','N')),
          city_position VARCHAR2(50) NOT NULL,
          city_stats VARCHAR2(200) NOT NULL,
          administrative_unit_name VARCHAR2(150) NOT NULL,
          administrative_unit_stats VARCHAR2(200) NOT NULL,
          country_name VARCHAR2(100) NOT NULL,
          country_stats VARCHAR2(200) NOT NULL,
          country_rating NUMBER(5,2) NOT NULL,
          official_language_name VARCHAR2(60) NOT NULL,
          currency_name VARCHAR2(200) NOT NULL,
          region_name VARCHAR2(100) NOT NULL,

          --technical columns
          creation_date         TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          valid_from            TIMESTAMP NOT NULL,
          valid_to              TIMESTAMP NOT NULL,
          source_system         VARCHAR2(20) NOT NULL CHECK (source_system IN ('db_env')),
          deleted_flag          VARCHAR2(1) NOT NULL CHECK (deleted_flag IN ('N','Y'))
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_owner.dwh_institution_location_dim TO autonomous_dw_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_INSTITUTION_LOCATION_DIM'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_INSTITUTION_LOCATION_DIM table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_INSTITUTION_LOCATION_DIM table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  autonomous_dw_owner.dwh_institution_location_dim IS ''The table contains location of the institution where students graduate.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.institution_location_key IS ''The Surrogate key of the table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.location_address_code IS ''The primary key from source system''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.location_address IS ''The full address of the location''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.postal_code IS ''The postal code of the address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.location_details IS ''The details of the location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.city_name IS ''The name of the city of location address.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.capital_city_flag IS ''The flag indicating if the city is the capital''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.city_position IS ''The geographical position of the location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.city_stats IS ''The city stats of location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.administrative_unit_name IS ''The name of the administrative unit of the location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.administrative_unit_stats IS ''The administrative unit stats of location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.country_name IS ''The country name of location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.country_stats IS ''The country stats of location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.country_rating IS ''The country rating of location address''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.official_language_name IS ''The name of the official language from that location''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.currency_name IS ''The name of the currency from that location''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.region_name IS ''The name of the region from that location''';

-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.valid_from IS ''Technical Column - The timestamp indicating when the record becomes effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.valid_to IS ''Technical Column - The timestamp indicating when the record stops being effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_institution_location_dim.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_TECHNOLOGY_TYPE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_INSTITUTION_LOCATION_KEY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_dw_owner.seq_institution_location_key';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_institution_location_key
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_INSTITUTION_LOCATION_KEY';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_INSTITUTION_LOCATION_KEY sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_INSTITUTION_LOCATION_KEY sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_INSTITUTION_LOCATION_KEY_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_institution_location_key_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_institution_location_key_pk
          BEFORE INSERT ON autonomous_dw_owner.dwh_institution_location_dim
          FOR EACH ROW
          WHEN (NEW.institution_location_key IS NULL)
          BEGIN
             SELECT seq_institution_location_key.NEXTVAL INTO :NEW.institution_location_key FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_INSTITUTION_LOCATION_KEY_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_INSTITUTION_LOCATION_KEY_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_INSTITUTION_LOCATION_KEY_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_INSTITUTION_LOCATION_DIM_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_institution_location_dim_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_dwh_institution_location_dim_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_institution_location_dim
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
        -- creation metadata
        :NEW.creation_date := CURRENT_TIMESTAMP;
        :NEW.created_by := ''ETL_INSTITUTION_LOCATION_DAILY_PROCESS'';

        -- update metadata
        :NEW.last_update_date := :NEW.creation_date;
        :NEW.last_updated_by := ''ETL_INSTITUTION_LOCATION_DAILY_PROCESS'';

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
        :NEW.last_updated_by := ''ETL_INSTITUTION_LOCATION_DAILY_PROCESS'';

    END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_INSTITUTION_LOCATION_DIM_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_INSTITUTION_LOCATION_DIM_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_DWH_INSTITUTION_LOCATION_DIM_TECH_COL trigger for technical columns was created.');


DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/


INSERT INTO autonomous_dw_owner.dwh_institution_location_dim (
    location_address_code,
    location_address,
    postal_code,
    location_details,
    city_name,
    capital_city_flag,
    city_position,
    city_stats,
    administrative_unit_name,
    administrative_unit_stats,
    country_name,
    country_stats,
    country_rating,
    official_language_name,
    currency_name,
    region_name
)
SELECT
    loc.location_id AS location_address_code,
    loc.street_name || ' ' || loc.street_number AS location_address,
    loc.postal_code AS postal_code,
    TRIM(
        NVL(loc.building, '') || ' ' ||
        NVL(loc.staircase, '') || ' ' ||
        NVL(loc.floor, '') || ' ' ||
        NVL(loc.appartment_number,'')
    ) AS location_details,
    c.name AS city_name,
    CASE WHEN c.is_capital = 'Y' THEN 'Y' ELSE 'N' END AS capital_city_flag,
    c.latitude || ',' || c.longitude AS city_position,
    c.population || ' people, ' || c.area || ' km2' AS city_stats,
    aut.name ||' '||au.name AS administrative_unit_name,
    au.no_cities || ' cities, '||au.population || ' people, ' || au.area || ' km2,' AS administrative_unit_stats,
    co.name AS country_name,
    co.population || ' people, ' || co.area || ' km2' AS country_stats,
    co.rating AS country_rating,
    lang.name AS official_language_name,
    cur.name AS currency_name,
    reg.name AS region_name
FROM autonomous_dw_landing_owner.dwh_user_spec us
JOIN autonomous_dw_landing_owner.dwh_specialization sp
    ON us.specialization_id = sp.specialization_id
JOIN autonomous_dw_landing_owner.dwh_institution inst
    ON sp.institution_id = inst.institution_id
JOIN autonomous_dw_landing_owner.dwh_location loc
    ON inst.location_id = loc.location_id
JOIN autonomous_dw_landing_owner.dwh_city c
    ON loc.city_code = c.city_code
JOIN autonomous_dw_landing_owner.dwh_administrative_unit au
    ON c.administrative_unit_id = au.administrative_unit_id
JOIN autonomous_dw_landing_owner.dwh_administrative_unit_type aut
    ON au.administrative_unit_type_id = aut.administrative_unit_type_id    
JOIN autonomous_dw_landing_owner.dwh_country co
    ON au.country_id = co.country_id
JOIN autonomous_dw_landing_owner.dwh_region reg
    ON co.region_id = reg.region_id
LEFT JOIN autonomous_dw_landing_owner.dwh_language lang
    ON co.official_lang_code = lang.lang_code
LEFT JOIN autonomous_dw_landing_owner.dwh_currency cur
    ON co.currency_code = cur.currency_code;
    