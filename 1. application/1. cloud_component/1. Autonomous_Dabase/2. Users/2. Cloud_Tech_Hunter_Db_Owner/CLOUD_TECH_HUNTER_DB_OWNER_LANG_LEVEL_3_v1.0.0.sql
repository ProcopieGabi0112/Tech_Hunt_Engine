--CLOUD_TECH_HUNTER_DB_OWNER_LANG_LEVEL_3_v1.0.0
--"LANG_LEVEL TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--DELETE TABLE LANGUAGE IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'LANG_LEVEL'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE tech_hunter_db_owner.lang_level CASCADE CONSTRAINTS';
END IF;
--CREATE LANG_LEVEL TABLE;
v_sql := q'[
CREATE TABLE tech_hunter_db_owner.lang_level (
  lang_level_id NUMBER(38,0) PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  nivel VARCHAR2(30) NOT NULL,
  lang_code NUMBER(38,0) NOT NULL,
  validity_period NUMBER(3,0) DEFAULT 0,
  rating NUMBER(5,2) DEFAULT 0,
  description VARCHAR2(100),
  creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  created_by            VARCHAR2(50) NOT NULL,
  last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  last_updated_by       VARCHAR2(50) NOT NULL,
  source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
  sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
  sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
  last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL,
  CONSTRAINT fk_lang_code
        FOREIGN KEY (lang_code)
        REFERENCES language(lang_code)
        ON DELETE CASCADE
)
 ]';
 EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'LANG_LEVEL'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The LANG_LEVEL table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The LANG_LEVEL table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE tech_hunter_db_owner.lang_level IS ''The table contains the certifications of every language that the students can have''';
-- Comentarii pe coloane
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.lang_level_id IS ''The primary key of the lang level table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.name IS ''The name of the certification''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.nivel IS ''The level of the certification''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.lang_code IS ''The language of the certification''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.validity_period IS ''The validity period of the certification (in months)''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.rating IS ''The rating of this certification, calculated based on the number of students that consider this certification is helpfull.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.description IS ''The description of the certification''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.lang_level.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_LANG_LEVEL_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_LANG_LEVEL_ID'
AND min_value = 1;
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_lang_level_id';
END IF;

EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_lang_level_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
   ';

--VERIFY IF THE SEQUENCE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_LANG_LEVEL_ID'
AND min_value = 1;
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_LANG_LEVEL_ID sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_LANG_LEVEL_ID sequence was created.');

--CREATE TRIGGER FOR PRIMARY KEY
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'trg_lang_level_id_pk';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_lang_level_id_pk';
END IF;
--CREATE TRIGGER
v_sql := '
CREATE OR REPLACE TRIGGER trg_lang_level_id_pk
BEFORE INSERT ON tech_hunter_db_owner.lang_level
FOR EACH ROW
WHEN (NEW.lang_level_id IS NULL)
BEGIN
  SELECT seq_lang_level_id.NEXTVAL INTO :NEW.lang_level_id FROM dual;
END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_LANG_LEVEL_ID_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_LANG_LEVEL_ID_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_LANG_LEVEL_ID_PK trigger for primary key was created.');

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'trg_lang_level_tech_col';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_lang_level_techn_col';
END IF;
v_sql := '
CREATE OR REPLACE TRIGGER trg_lang_level_tech_col
BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.lang_level
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
WHERE trigger_name = 'TRG_LANG_LEVEL_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_LANG_LEVEL_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_LANG_LEVEL_TECH_COL for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/