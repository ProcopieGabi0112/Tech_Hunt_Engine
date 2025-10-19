--CLOUD_TECH_HUNTER_DB_OWNER_INSTITUTION_5_v1.0.0
--"INSTITUTION TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--DELETE TABLE INSTITUTION IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'INSTITUTION'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE tech_hunter_db_owner.institution CASCADE CONSTRAINTS';
END IF;
--CREATE INSTITUTION TABLE;
v_sql := q'[
        CREATE TABLE tech_hunter_db_owner.institution (
          institution_id        NUMBER(38,0) PRIMARY KEY,
          name                  VARCHAR2(100) NOT NULL,
          website               VARCHAR2(250),
          founding_date         DATE NOT NULL,
          rating                NUMBER(5,2) DEFAULT 0 NOT NULL,
          description           VARCHAR2(100),
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'INSTITUTION'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The INSTITUTION table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The INSTITUTION table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE tech_hunter_db_owner.institution IS ''The table lists the institutions where the students learned.''';
-- BUSINESS COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.institution_id IS ''The primary key of the institution table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.name IS ''The name of the institution''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.website IS ''The werbsite of the institution''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.founding_date IS ''The founding date of the institution''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.rating IS ''The rating of the institution''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.description IS ''The description of the institution''';
-- TECHNICAL COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.institution.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_LANGUAGE_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_INSTITUTION_ID';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE tech_hunter_db_owner.seq_institution_id';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_institution_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_INSTITUTION_ID';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_INSTITUTION_ID sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_INSTITUTION_ID sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'trg_institution_id_pk';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_institution_id_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_institution_id_pk
          BEFORE INSERT ON tech_hunter_db_owner.institution
          FOR EACH ROW
          WHEN (NEW.institution_id IS NULL)
          BEGIN
             SELECT seq_institution_id.NEXTVAL INTO :NEW.institution_id FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_INSTITUTION_ID_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_INSTITUTION_ID_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_INSTITUTION_ID_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_INSTITUTION_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_institution_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_institution_tech_col
            BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.institution
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
WHERE trigger_name = 'TRG_INSTITUTION_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_INSTITUTION_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_INSTITUTION_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/