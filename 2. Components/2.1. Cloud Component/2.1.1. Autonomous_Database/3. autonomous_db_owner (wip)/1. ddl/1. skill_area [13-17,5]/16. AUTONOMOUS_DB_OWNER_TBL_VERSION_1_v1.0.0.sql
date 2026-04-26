--AUTONOMOUS_DB_OWNER_TBL_VERSION_1_v1.0.0
--"VERSION TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DB_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DB_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE VERSION IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'VERSION'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.version CASCADE CONSTRAINTS';
END IF;
--CREATE TECHNOLOGY TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.version (
          --business columns
          version_code	            NUMBER(38,0) PRIMARY KEY,
          name	                    VARCHAR2(100),
          description               VARCHAR2(200),
          release_date	            DATE NOT NULL,
          end_of_life               DATE,
          new_features              VARCHAR2(150) NOT NULL,
          unsolved_problems         VARCHAR2(150),
          creator	                VARCHAR2(150) NOT NULL,
          developer_popularity      NUMBER(5,2)  NOT NULL,
          community_support         NUMBER(5,2) NOT NULL,
          industry_usage_score      NUMBER(5,2)  NOT NULL,
          knowledge_score           NUMBER(5,2) NOT NULL,
          skills_rating             NUMBER(5,2) DEFAULT 0 NOT NULL,
          rating                    NUMBER(5,2) 
          GENERATED ALWAYS AS (
          ROUND(
            ( 0.30 * industry_usage_score +
              0.20 * community_support +
              0.20 * developer_popularity +
              0.15 * (100 - skills_rating) +
              0.15 * knowledge_score
            ), 2)
          ) VIRTUAL,
          technology_code           NUMBER(38,0),
          
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
          CONSTRAINT fk_technology_code FOREIGN KEY (technology_code) REFERENCES technology (technology_code)
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'VERSION'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The VERSION table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The VERSION table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.version IS ''The table contains the informations about version of each technology.''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.version_code IS ''The code of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.name IS ''The name of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.description IS ''The description of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.release_date IS ''The release date of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.end_of_life IS ''The end of life of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.new_features IS ''The new features of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.unsolved_problems IS ''The unsolved problems of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.creator IS ''The creator of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.developer_popularity IS ''The developer popularity score of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.community_support IS ''The comunity support score of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.industry_usage_score IS ''The industry usage score of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.knowledge_score IS ''The knowledge score of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.skills_rating IS ''The skills rating of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.rating IS ''The overall rating of the technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.technology_code IS ''The code of the technology''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.version.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_VERSION_CODE FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_VERSION_CODE';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.seq_version_code';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_version_code
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_VERSION_CODE';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_VERSION_CODE sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_VERSION_CODE sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_VERSION_CODE_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_version_code_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_version_code_pk
          BEFORE INSERT ON autonomous_db_owner.version
          FOR EACH ROW
          WHEN (NEW.version_code IS NULL)
          BEGIN
             SELECT seq_version_code.NEXTVAL INTO :NEW.version_code FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_VERSION_CODE_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_VERSION_CODE_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_VERSION_CODE_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_VERSION_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_version_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_version_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.version
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
                    :NEW.created_by := USER;
                    :NEW.last_updated_by := USER;
                    :NEW.creation_date := CURRENT_TIMESTAMP;
                    :NEW.last_update_date := CURRENT_TIMESTAMP;
                 END IF;

                 IF UPDATING THEN
                    :NEW.last_update_date := CURRENT_TIMESTAMP;
                    :NEW.last_updated_by := USER;
                 END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_VERSION_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_VERSION_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_VERSION_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR POPULATING THE rating column FROM TECHNOLOGY TABLE
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_RATING_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_technology_rating_sync';
END IF;
--CREATE TRIGGER
v_sql := '  
        CREATE OR REPLACE TRIGGER trg_technology_rating_sync
        AFTER INSERT OR UPDATE OR DELETE ON autonomous_db_owner.version
        DECLARE
        BEGIN
              -- Recalculează rating pentru toate tehnologiile afectate 
              UPDATE autonomous_db_owner.technology t 
              SET t.rating = ( SELECT NVL(AVG(v.rating), 0) 
                               FROM autonomous_db_owner.version v 
                               WHERE v.technology_code = t.technology_code );
        END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_TECHNOLOGY_RATING_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_TECHNOLOGY_RATING_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_TECHNOLOGY_RATING_SYNC trigger for populating the rating column from technology table.');

DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/