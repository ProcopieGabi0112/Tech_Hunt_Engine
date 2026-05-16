--AUTONOMOUS_DW_OWNER_DWH_USER_SKILL_DIM_TBL_1_v1.0.0
--"DWH_USER_SKILL_DIM TABLE"
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
AND table_name = 'DWH_USER_SKILL_DIM'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_owner.dwh_user_skill_dim CASCADE CONSTRAINTS';
END IF;


--CREATE UTILIZATORI TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_owner.dwh_user_skill_dim (

          --business columns
          user_skill_key          NUMBER(38,0) PRIMARY KEY,
          skill_code              NUMBER(38,0) NOT NULL,
          skill_name              VARCHAR2(150) NOT NULL,
          skill_rating            NUMBER(5,2) NOT NULL,
          version_code            NUMBER(38,0) NOT NULL,
          version_name            VARCHAR2(100) NOT NULL,
          version_details         VARCHAR2(400) NOT NULL,
          version_rating          NUMBER(5,2) NOT NULL,
          technology_code         NUMBER(38,0) NOT NULL,
          technology_name         VARCHAR2(100) NOT NULL,
          technology_details      VARCHAR2(400) NOT NULL,
          technology_rating       NUMBER(5,2) NOT NULL,
          technology_type_code    NUMBER(38,0) NOT NULL,
          technology_type_name    VARCHAR2(50) NOT NULL,
          technology_type_rating  NUMBER(5,2) NOT NULL,
          overall_skill_rating    NUMBER(5,2) NOT NULL,
          
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
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_owner.dwh_user_skill_dim TO autonomous_dw_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_USER_SKILL_DIM'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_USER_SKILL_DIM table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_USER_SKILL_DIM table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  autonomous_dw_owner.dwh_user_skill_dim IS ''The table contains information about the skill that a user know.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.user_skill_key IS ''The Surrogate key of the table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.skill_code IS ''The primary key from skill table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.skill_name IS ''The name of the skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.skill_rating IS ''The rating of the skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.version_code IS ''The primary key from version table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.version_name IS ''The name of the version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.version_details IS ''The details about version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.version_rating IS ''The rating of the version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_code IS ''The primary key from technology table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_name IS ''The name of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_details IS ''The details about technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_rating IS ''The rating of the technology''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_type_code IS ''The primary key from technology type table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_type_name IS ''The name of the technology type''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.technology_type_rating IS ''The rating of the technology type''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.overall_skill_rating IS ''The rating of the skill over version,technology and technology_type''';

-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.valid_from IS ''Technical Column - The timestamp indicating when the record becomes effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.valid_to IS ''Technical Column - The timestamp indicating when the record stops being effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_skill_dim.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_TECHNOLOGY_TYPE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_USER_SKILL_KEY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_dw_owner.seq_user_skill_key';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_user_skill_key
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_USER_SKILL_KEY';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_USER_SKILL_KEY sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_USER_SKILL_KEY sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_USER_SKILL_KEY_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_user_skill_key_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_user_skill_key_pk
          BEFORE INSERT ON autonomous_dw_owner.dwh_user_skill_dim
          FOR EACH ROW
          WHEN (NEW.user_skill_key IS NULL)
          BEGIN
             SELECT seq_user_skill_key.NEXTVAL INTO :NEW.user_skill_key FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_USER_SKILL_KEY_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_USER_SKILL_KEY_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_USER_SKILL_KEY_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_USER_SKILL_DIM_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_user_skill_dim_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_dwh_user_skill_dim_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_user_skill_dim
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
        -- creation metadata
        :NEW.creation_date := CURRENT_TIMESTAMP;
        :NEW.created_by := ''ETL_USER_SKILL_DAILY_PROCESS'';

        -- update metadata
        :NEW.last_update_date := :NEW.creation_date;
        :NEW.last_updated_by := ''ETL_USER_SKILL_DAILY_PROCESS'';

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
        :NEW.last_updated_by := ''ETL_USER_SKILL_DAILY_PROCESS'';

    END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_USER_SKILL_DIM_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_USER_SKILL_DIM_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_DWH_USER_SKILL_DIM_TECH_COL trigger for technical columns was created.');


DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/