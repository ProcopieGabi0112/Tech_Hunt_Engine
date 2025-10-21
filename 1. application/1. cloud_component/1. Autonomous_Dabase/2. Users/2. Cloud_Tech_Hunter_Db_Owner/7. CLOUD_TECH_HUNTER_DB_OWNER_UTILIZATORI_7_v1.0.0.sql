--CLOUD_TECH_HUNTER_DB_OWNER_UTILIZATORI_7_v1.0.0
--"UTILIZATORI TABLE"
SET SERVEROUTPUT ON;
DECLARE
  v_count NUMBER;
  v_text  VARCHAR2(4000);
  v_sql CLOB;
BEGIN
DBMS_OUTPUT.PUT_LINE('[1.] Script running...');

--DELETE TABLE UTILIZATORI IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'UTILIZATORI'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE tech_hunter_db_owner.utilizatori CASCADE CONSTRAINTS';
END IF;
--CREATE UTILIZATORI TABLE;
v_sql := q'[
        CREATE TABLE tech_hunter_db_owner.utilizatori (
		  user_id               NUMBER(38,0),
          email                 VARCHAR2(70),
          first_name            VARCHAR2(50) NOT NULL,
          last_name             VARCHAR2(50) NOT NULL,
          user_name             VARCHAR2(200) GENERATED ALWAYS AS (INITCAP(first_name) || INITCAP(last_name) || TO_CHAR(user_id) ) VIRTUAL,
          email_app             VARCHAR2(300) GENERATED ALWAYS AS (SUBSTR(email, 1, INSTR(email, '@') - 1) || '@tech_hunter.com') VIRTUAL,  
          password	            VARCHAR2(100) NOT NULL,
          date_of_birth	        DATE NOT NULL,
          phone	                VARCHAR2(15),
          gender	            VARCHAR2(1) CHECK (gender IN ('M','F')),
          native_lang_code	    NUMBER(38,0) NOT NULL,
          account_status	    VARCHAR2(20) DEFAULT 'unlocked' NOT NULL CHECK (account_status IN ('unlocked','locked')),
          supervizor_id	        NUMBER(38,0),
          report_sent_flag	    VARCHAR2(1) DEFAULT 'N' NOT NULL CHECK (report_sent_flag IN ('N','Y')),                                                      
                     
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL,
          CONSTRAINT pk_utilizatori_id_email PRIMARY KEY (user_id, email),
          CONSTRAINT uk_utilizatori_user_id UNIQUE (user_id),
	      CONSTRAINT uk_utilizatori_email UNIQUE (email)
          CONSTRAINT fk_native_lang_code FOREIGN KEY (native_lang_code) REFERENCES language(lang_code)
)
    ]';
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE '
  ALTER TABLE tech_hunter_db_owner.utilizatori
  ADD CONSTRAINT fk_supervizor_user_id FOREIGN KEY (supervizor_id)
  REFERENCES tech_hunter_db_owner.utilizatori(user_id)
';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'UTILIZATORI'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The UTILIZATORI table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The UTILIZATORI table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  tech_hunter_db_owner.utilizatori IS ''The table contains the users of the application.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.user_id IS ''The primary key of the utilizatori table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.email IS ''The primary key of the utilizatori table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.first_name IS ''The first name of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.last_name IS ''The last name of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.user_name	IS ''The user name of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.email_app	IS ''The email that user received from application''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.password IS ''The password of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.date_of_birth	IS ''The birth date of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.phone	IS ''The phone number of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.gender IS ''The gender of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.native_lang_code IS ''The native language of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.account_status IS ''The account status of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.supervizor_id	IS ''The supervizor id of the user''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.report_sent_flag IS ''The flag that indicates if the report was sent or not''';
-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.utilizatori.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_UTILIZATORI_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_UTILIZATORI_ID';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE tech_hunter_db_owner.seq_utilizatori_id';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_utilizatori_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_UTILIZATORI_ID';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_UTILIZATORI_ID sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_UTILIZATORI_ID sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'trg_utilizatori_id_pk';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_utilizatori_id_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_utilizatori_id_pk
          BEFORE INSERT ON tech_hunter_db_owner.utilizatori
          FOR EACH ROW
          WHEN (NEW.user_id IS NULL)
          BEGIN
             SELECT seq_utilizatori_id.NEXTVAL INTO :NEW.user_id FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_UTILIZATORI_ID_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_UTILIZATORI_ID_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_UTILIZATORI_ID_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_UTILIZATORI_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_utilizatori_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_utilizatori_tech_col
            BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.utilizatori
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
WHERE trigger_name = 'TRG_UTILIZATORI_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_UTILIZATORI_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_UTILIZATORI_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;

/
