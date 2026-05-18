--AUTONOMOUS_DW_OWNER_DWH_USER_DIM_TBL_1_v1.0.0
--"DWH_USER_DIM TABLE"
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
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDW"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE dwh_user_dim IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_USER_DIM'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_owner.dwh_user_dim CASCADE CONSTRAINTS';
END IF;

--CREATE dwh_user_dim TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_owner.dwh_user_dim (

          --business columns
          user_key NUMBER(38,0) PRIMARY KEY,
          user_id NUMBER(38,0) NOT NULL,
          user_email VARCHAR2(200) NOT NULL,
          full_name VARCHAR2(100) NOT NULL,
          date_of_birth DATE NOT NULL,
          user_age NUMBER(3,0) NOT NULL,
          phone VARCHAR2(15) NOT NULL,
          gender VARCHAR2(1) NOT NULL,
          creation_account_date DATE NOT NULL,
          account_age_days NUMBER(10,0) NOT NULL,
          days_since_last_update NUMBER(10,0) NOT NULL,
          is_recently_active VARCHAR2(1) NOT NULL,
          is_new_user VARCHAR2(1) NOT NULL,
          native_lang_code NUMBER(38,0) NOT NULL,
          native_language_name VARCHAR2(60) NOT NULL,
          user_location_key NUMBER(38,0) NOT NULL,

          --technical columns
          creation_date         TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          valid_from            TIMESTAMP NOT NULL,
          valid_to              TIMESTAMP NOT NULL,
          source_system         VARCHAR2(20) NOT NULL CHECK (source_system IN ('db_env')),
          deleted_flag          VARCHAR2(1) NOT NULL CHECK (deleted_flag IN ('N','Y')),
          CONSTRAINT fk_user_dim_location
          FOREIGN KEY (user_location_key)
          REFERENCES autonomous_dw_owner.dwh_user_location_dim (user_location_key)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_owner.dwh_user_dim TO autonomous_dw_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_USER_DIM'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_USER_DIM table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_USER_DIM table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  autonomous_dw_owner.dwh_user_dim IS ''The table contains the user of institution where the users graduated''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.user_key IS ''Surrogate key of the user dimension.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.user_id IS ''Natural key of the user from source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.user_email IS ''Primary email address of the user.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.full_name IS ''Full name of the user (first_name + last_name).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.date_of_birth IS ''User date of birth.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.user_age IS ''Derived age of the user based on date_of_birth.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.phone IS ''Phone number of the user.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.gender IS ''Gender of the user (M/F).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.creation_account_date IS ''The date when the user account was created in the source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.account_age_days IS ''Derived feature: number of days since account creation.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.days_since_last_update IS ''Derived feature: number of days since last account update.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.is_recently_active IS ''Derived feature: Y/N flag indicating if user was active in the last 30 days.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.is_new_user IS ''Derived feature: Y/N flag indicating if user account is newer than 7 days.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.native_lang_code IS ''Natural key referencing the user native language.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.native_language_name IS ''The name of the user native language.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.user_location_key IS ''Foreign key referencing the user location dimension.''';

-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.valid_from IS ''Technical Column - The timestamp indicating when the record becomes effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.valid_to IS ''Technical Column - The timestamp indicating when the record stops being effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_user_dim.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_TECHNOLOGY_TYPE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_USER_KEY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_dw_owner.seq_user_key';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_user_key
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_USER_KEY';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_USER_KEY sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_USER_KEY sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_USER_KEY_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_user_key_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_user_key_pk
          BEFORE INSERT ON autonomous_dw_owner.dwh_user_dim
          FOR EACH ROW
          WHEN (NEW.user_key IS NULL)
          BEGIN
             SELECT seq_user_key.NEXTVAL INTO :NEW.user_key FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_USER_KEY_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_USER_KEY_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_USER_KEY_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_USER_DIM_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_user_dim_tech_col';
END IF;
--CREATE TRIGGER
--CREATE TRIGGER
v_sql := q'[
CREATE OR REPLACE TRIGGER trg_dwh_user_dim_tech_col
BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_user_dim
FOR EACH ROW
BEGIN

    IF INSERTING THEN

        -- creation metadata
        :NEW.creation_date := CURRENT_TIMESTAMP;
        :NEW.created_by := 'ETL_USER_DAILY_PROCESS';

        -- update metadata
        :NEW.last_update_date := :NEW.creation_date;
        :NEW.last_updated_by := 'ETL_USER_DAILY_PROCESS';

        -- validity (SCD1 → no history)
        :NEW.valid_from := CURRENT_TIMESTAMP;

        :NEW.valid_to :=
            TO_TIMESTAMP(
                '9999-12-31 23:59:59',
                'YYYY-MM-DD HH24:MI:SS'
            );

        -- source system
        IF :NEW.source_system IS NULL THEN
            :NEW.source_system := 'db_env';
        END IF;

        -- deleted flag
        IF :NEW.deleted_flag IS NULL THEN
            :NEW.deleted_flag := 'N';
        END IF;

    END IF;

    IF UPDATING THEN

        -- update metadata
        :NEW.last_update_date := CURRENT_TIMESTAMP;
        :NEW.last_updated_by := 'ETL_USER_DAILY_PROCESS';

    END IF;

END;
]';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_USER_DIM_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_USER_DIM_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_DWH_USER_DIM_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR POPULATING INSTITUTION AGE SYNCs
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_USER_DIM_NEW_FEATURES_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_user_dim_new_features_sync';
END IF;
--CREATE TRIGGER
v_sql := q'[
CREATE OR REPLACE TRIGGER autonomous_dw_owner.trg_dwh_user_dim_new_features_sync
BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_user_dim
FOR EACH ROW
BEGIN

    --------------------------------------------------------------------
    -- USER AGE
    --------------------------------------------------------------------
    IF :NEW.date_of_birth IS NOT NULL THEN

        :NEW.user_age :=
            EXTRACT(YEAR FROM CURRENT_DATE)
            - EXTRACT(YEAR FROM :NEW.date_of_birth);

    ELSE

        :NEW.user_age := 0;

    END IF;

    --------------------------------------------------------------------
    -- ACCOUNT AGE
    --------------------------------------------------------------------
    IF :NEW.creation_account_date IS NOT NULL THEN

        :NEW.account_age_days :=
            TRUNC(CURRENT_DATE - :NEW.creation_account_date);

    ELSE

        :NEW.account_age_days := 0;

    END IF;

--------------------------------------------------------------------
-- DAYS SINCE LAST UPDATE
--------------------------------------------------------------------
IF :NEW.last_update_date IS NOT NULL THEN

    :NEW.days_since_last_update :=
        TRUNC(
            CURRENT_DATE
            - CAST(:NEW.last_update_date AS DATE)
        );

ELSE

    :NEW.days_since_last_update := 0;

END IF;

--------------------------------------------------------------------
-- IS RECENTLY ACTIVE
--------------------------------------------------------------------
IF :NEW.last_update_date IS NOT NULL
   AND (
        CURRENT_DATE
        - CAST(:NEW.last_update_date AS DATE)
       ) <= 30 THEN

    :NEW.is_recently_active := 'Y';

ELSE

    :NEW.is_recently_active := 'N';

-------------------------------------------------------------------- 
-- IS NEW USER 
-------------------------------------------------------------------- 
    IF :NEW.creation_account_date IS NOT NULL AND (CURRENT_DATE - :NEW.creation_account_date) <= 7 THEN 
        :NEW.is_new_user := 'Y'; 
    ELSE 
        :NEW.is_new_user := 'N'; END IF;

END IF;

END;
]';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_USER_DIM_NEW_FEATURES_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_USER_DIM_NEW_FEATURES_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_DWH_USER_DIM_NEW_FEATURES_SYNC trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/