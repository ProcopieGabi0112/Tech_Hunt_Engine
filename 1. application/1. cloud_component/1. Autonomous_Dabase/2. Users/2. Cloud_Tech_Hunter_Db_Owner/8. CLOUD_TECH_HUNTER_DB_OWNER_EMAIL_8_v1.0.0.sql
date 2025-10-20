--CLOUD_TECH_HUNTER_DB_OWNER_EMAIL_7_v1.0.0
--"EMAIL TABLE"
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
AND table_name = 'EMAIL'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE tech_hunter_db_owner.email CASCADE CONSTRAINTS';
END IF;
--CREATE EMAIL TABLE;
v_sql := q'[
        CREATE TABLE tech_hunter_db_owner.email (
		  email_code            NUMBER(38,0) PRIMARY KEY,
          subject               VARCHAR2(250) DEFAULT '<no subject>',
          content               VARCHAR2(500)  DEFAULT '<no content>',
          arrival_time          TIMESTAMP NOT NULL,
          reply_to_email        NUMBER(38,0),
          receiver              NUMBER(38,0) NOT NULL,
          sender                NUMBER(38,0) NOT NULL ,
          importance            VARCHAR2(50) DEFAULT 'Not Important' NOT NULL CHECK (importance IN ('Not Important','Medium Importance','Very Important')),
		              
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL,
		  CONSTRAINT fk_reply_to_email_code FOREIGN KEY (reply_to_email) REFERENCES email(email_code),
		  CONSTRAINT fk_user_receiver_id FOREIGN KEY (receiver) REFERENCES utilizatori(user_id),
		  CONSTRAINT fk_user_sender_id   FOREIGN KEY (sender) REFERENCES utilizatori(user_id)
)
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'TECH_HUNTER_DB_OWNER'
AND table_name = 'EMAIL'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The EMAIL table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The EMAIL table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE  tech_hunter_db_owner.email IS ''The table contains the email from all users to other users.''';
-- BUSINESS COLUMNS COMMENT                              
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.email_code IS ''The primary key of the email table''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.subject IS ''The subject of the email''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.content IS ''The content of the email''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.arrival_time IS ''The arrival time of the email''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.reply_to_email IS ''References the original email being replied''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.receiver IS ''The receiver of the email''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.sender IS ''The sender of the email''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.importance IS ''The importance of the email''';
-- TECHNICAL COLUMNS COMMENT                             
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN tech_hunter_db_owner.email.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';
--CREATE SEQUENCE SEQ_EMAIL_CODE FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_EMAIL_CODE';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE tech_hunter_db_owner.seq_email_code';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_email_code
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_EMAIL_CODE';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_EMAIL_CODE sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_EMAIL_CODE sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'trg_email_code_pk';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_email_code_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_email_code_pk
          BEFORE INSERT ON tech_hunter_db_owner.email
          FOR EACH ROW
          WHEN (NEW.email_code IS NULL)
          BEGIN
             SELECT seq_email_code.NEXTVAL INTO :NEW.email_code FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_EMAIL_CODE_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_EMAIL_CODE_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_EMAIL_CODE_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_EMAIL_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER tech_hunter_db_owner.trg_email_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_email_tech_col
            BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.email
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
WHERE trigger_name = 'TRG_EMAIL_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_EMAIL_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_EMAIL_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/