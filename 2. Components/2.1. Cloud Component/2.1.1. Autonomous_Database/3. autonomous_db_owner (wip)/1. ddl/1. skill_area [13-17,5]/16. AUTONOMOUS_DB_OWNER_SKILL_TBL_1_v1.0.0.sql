--AUTONOMOUS_DB_OWNER_SKILL_TBL_1_v1.0.0
--"SKILL TABLE"
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
AND table_name = 'SKILL'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.skill CASCADE CONSTRAINTS';
END IF;
--CREATE TECHNOLOGY TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.skill (
          --business columns
          skill_code NUMBER(38,0) PRIMARY KEY,
          name VARCHAR2(200) NOT NULL,
          prerequisite_knowledge NUMBER(5,2) NOT NULL,
          learning_difficulty NUMBER(5,2) NOT NULL,
          implementation_difficulty NUMBER(5,2) NOT NULL,
          cross_platform_applicability NUMBER(5,2) NOT NULL,
          rating GENERATED ALWAYS AS (
          ROUND(
                 0.35 * (prerequisite_knowledge) +
                 0.30 * (learning_difficulty) +
                 0.20 * cross_platform_applicability +
                 0.15 * (implementation_difficulty)
          , 2)) VIRTUAL,
          description VARCHAR2(200),
          last_version_code NUMBER(38,0) NOT NULL,
          first_version_code NUMBER(38,0),
          
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
          CONSTRAINT fk_last_version_code FOREIGN KEY (last_version_code) REFERENCES version (version_code),
          CONSTRAINT fk_first_version_code FOREIGN KEY (first_version_code) REFERENCES version (version_code)
        )
    ]';
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_db_owner.skill TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'SKILL'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SKILL table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SKILL table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.skill IS ''The table contains the informations about the skills of each technology version.''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.skill_code IS ''The code of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.name IS ''The name of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.prerequisite_knowledge IS ''The prerequisite knowkedge score of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.learning_difficulty IS ''The learning difficulty score of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.implementation_difficulty IS ''The implementation difficulty score of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.cross_platform_applicability IS ''The cross platform applicability score of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.rating IS ''The rating of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.description IS ''The description of the technology skill''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.last_version_code IS ''The code of the last technology version''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.first_version_code IS ''The code of the first technology version''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.skill.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_SKILL_CODE FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_SKILL_CODE';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.seq_skill_code';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_skill_code
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_SKILL_CODE';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_SKILL_CODE sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_SKILL_CODE sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SKILL_CODE_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_skill_code_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_skill_code_pk
          BEFORE INSERT ON autonomous_db_owner.skill
          FOR EACH ROW
          WHEN (NEW.skill_code IS NULL)
          BEGIN
             SELECT seq_skill_code.NEXTVAL INTO :NEW.skill_code FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SKILL_CODE_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_SKILL_CODE_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_SKILL_CODE_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SKILL_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_skill_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_skill_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.skill
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
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_SKILL_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_SKILL_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_SKILL_TECH_COL trigger for technical columns was created.');

--CREATE TRIGGER FOR POPULATING THE rating column FROM TECHNOLOGY TABLE
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_VERSION_RATING_SYNC';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_version_rating_sync';
END IF;
--CREATE TRIGGER
v_sql := '  
        CREATE OR REPLACE TRIGGER trg_version_rating_sync
        AFTER INSERT OR UPDATE OR DELETE ON autonomous_db_owner.skill
        DECLARE
        BEGIN
              -- Recalculează skill_rating pentru toate versiunile afectate 
              UPDATE autonomous_db_owner.version v 
              SET v.skills_rating = ( SELECT NVL(AVG(s.rating), 0) 
                                      FROM autonomous_db_owner.skill s 
                                      WHERE s.last_version_code = v.version_code );
        END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_VERSION_RATING_SYNC';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_VERSION_RATING_SYNC trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[7.] The TRG_VERSION_RATING_SYNC trigger for populating the rating column from technology table.');

DBMS_OUTPUT.PUT_LINE('[8.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/