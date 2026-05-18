--AUTONOMOUS_DW_OWNER_DWH_SPECIALIZATION_DIM_TBL_1_v1.0.0
--"DWH_SPECIALIZATION_DIM TABLE"
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

--DELETE TABLE dwh_specialization_dim IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_SPECIALIZATION_DIM'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_owner.dwh_specialization_dim CASCADE CONSTRAINTS';
END IF;


--CREATE UTILIZATORI TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_owner.dwh_specialization_dim (

          --business columns
          specialization_key NUMBER(38,0) PRIMARY KEY,
          specialization_id  NUMBER(38,0) NOT NULL,
          institution_id NUMBER(38,0) NOT NULL,
          specialization_type_id NUMBER(38,0) NOT NULL,
          specialization_name VARCHAR2(200) NOT NULL,
          degree_type VARCHAR2(50) NOT NULL,
          employment_rate NUMBER(5,2) NOT NULL,
          teachers_feedback NUMBER(5,2) NOT NULL,
          courses_feedback NUMBER(5,2) NOT NULL,
          entry_difficulty NUMBER(5,2) NOT NULL,
          graduation_difficulty NUMBER(5,2) NOT NULL,
          industry_reputation NUMBER(5,2) NOT NULL,
          specialization_rating NUMBER(5,2) NOT NULL,
          specialization_type_name VARCHAR2(100) NOT NULL,
          specialization_type_score NUMBER(5,2) NOT NULL,
          institution_name VARCHAR2(200) NOT NULL,
          founding_year VARCHAR2(4) NOT NULL,
          institution_rating NUMBER(5,2) NOT NULL,

          feedback_score NUMBER(5,2) GENERATED ALWAYS AS ((teachers_feedback + courses_feedback) / 2) STORED,
          difficulty_score NUMBER(5,2) GENERATED ALWAYS AS ((entry_difficulty + graduation_difficulty) / 2) STORED,
          overall_score NUMBER(5,2) GENERATED ALWAYS AS (
                (specialization_rating +
                 industry_reputation +
                 employment_rate +
                 ((teachers_feedback + courses_feedback) / 2)
                ) / 4
            ) STORED,
          institution_age NUMBER(5,0) DEFAULT 0 NOT NULL,
          institution_reputation_score NUMBER(5,2) GENERATED ALWAYS AS (
                (institution_rating + specialization_type_score) / 2
            ) STORED,
          overall_specialization_rating NUMBER(5,2) GENERATED ALWAYS AS (
                (
                    (specialization_rating +
                     industry_reputation +
                     employment_rate +
                     ((teachers_feedback + courses_feedback) / 2)
                    ) / 4
                ) * 0.7
                +
                ((institution_rating + specialization_type_score) / 2) * 0.3
            ) STORED,


          institution_location_key NUMBER(38,0) NOT NULL,

          --technical columns
          creation_date         TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          valid_from            TIMESTAMP NOT NULL,
          valid_to              TIMESTAMP NOT NULL,
          source_system         VARCHAR2(20) NOT NULL CHECK (source_system IN ('db_env')),
          deleted_flag          VARCHAR2(1) NOT NULL CHECK (deleted_flag IN ('N','Y')),
          CONSTRAINT fk_spec_dim_location
          FOREIGN KEY (institution_location_key)
          REFERENCES autonomous_dw_owner.dwh_institution_location_dim (institution_location_key)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_dw_owner.dwh_specialization_dim TO autonomous_dw_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_OWNER'
AND table_name = 'DWH_SPECIALIZATION_DIM'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_SPECIALIZATION_DIM table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_SPECIALIZATION_DIM table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  autonomous_dw_owner.dwh_specialization_dim IS ''The table contains the specialization of institution where the users graduated''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_key IS ''Surrogate key of the specialization dimension.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_id IS ''Natural key of the specialization from source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.institution_id IS ''Natural key of the institution offering the specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_type_id IS ''Natural key of the specialization type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_name IS ''The name of the specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.degree_type IS ''The degree type associated with the specialization (e.g., Bachelor, Master).''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.employment_rate IS ''Employment rate of graduates from this specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.teachers_feedback IS ''Feedback score provided by teachers for this specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.courses_feedback IS ''Feedback score provided by students for the courses in this specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.entry_difficulty IS ''Difficulty level for entering the specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.graduation_difficulty IS ''Difficulty level for graduating from the specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.industry_reputation IS ''Reputation score of the specialization in the industry.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_rating IS ''Overall rating of the specialization from the source system.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_type_name IS ''The name of the specialization type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.specialization_type_score IS ''Complexity or difficulty score of the specialization type.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.institution_name IS ''The name of the institution offering the specialization.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.founding_year IS ''The founding year of the institution.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.institution_rating IS ''Overall rating of the institution.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.feedback_score IS ''Derived score: average between teachers_feedback and courses_feedback.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.difficulty_score IS ''Derived score: average between entry_difficulty and graduation_difficulty.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.overall_score IS ''Derived score: aggregated specialization performance indicator.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.institution_age IS ''Derived value: current year minus founding_year.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.institution_reputation_score IS ''Derived score: combination of institution rating and specialization type score.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.overall_specialization_rating IS ''Final aggregated rating combining specialization and institution metrics.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.institution_location_key IS ''Foreign key referencing the institution location dimension.''';

-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.valid_from IS ''Technical Column - The timestamp indicating when the record becomes effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.valid_to IS ''Technical Column - The timestamp indicating when the record stops being effective in the data warehouse.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_owner.dwh_specialization_dim.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_TECHNOLOGY_TYPE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_SPECIALIZATION_KEY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_dw_owner.seq_specialization_key';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_specialization_key
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_SPECIALIZATION_KEY';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_SPECIALIZATION_KEY sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_SPECIALIZATION_KEY sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_KEY_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_specialization_key_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_specialization_key_pk
          BEFORE INSERT ON autonomous_dw_owner.dwh_specialization_dim
          FOR EACH ROW
          WHEN (NEW.specialization_key IS NULL)
          BEGIN
             SELECT seq_specialization_key.NEXTVAL INTO :NEW.specialization_key FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SPECIALIZATION_KEY_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_SPECIALIZATION_KEY_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_SPECIALIZATION_KEY_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_SPECIALIZATION_DIM_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_specialization_dim_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_dwh_specialization_dim_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_specialization_dim
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
        -- creation metadata
        :NEW.creation_date := CURRENT_TIMESTAMP;
        :NEW.created_by := ''ETL_SPECIALIZATION_DAILY_PROCESS'';

        -- update metadata
        :NEW.last_update_date := :NEW.creation_date;
        :NEW.last_updated_by := ''ETL_SPECIALIZATION_DAILY_PROCESS'';

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
        :NEW.last_updated_by := ''ETL_SPECIALIZATION_DAILY_PROCESS'';

    END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_SPECIALIZATION_DIM_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_SPECIALIZATION_DIM_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_DWH_SPECIALIZATION_DIM_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR POPULATING INSTITUTION AGE SYNCs
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_SPEC_DIM_INSTITUTION_AGE_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_owner.trg_dwh_spec_dim_institution_age_sync';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER autonomous_dw_owner.trg_dwh_spec_dim_institution_age_sync
            BEFORE INSERT OR UPDATE ON autonomous_dw_owner.dwh_specialization_dim
            FOR EACH ROW
            BEGIN
                  -- Calculează vârsta instituției pe baza anului fondării
                  :NEW.institution_age := EXTRACT(YEAR FROM CURRENT_DATE) - TO_NUMBER(:NEW.founding_year);
            END;
';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_SPEC_DIM_INSTITUTION_AGE_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_SPEC_DIM_INSTITUTION_AGE_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_DWH_SPEC_DIM_INSTITUTION_AGE_SYNC trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/