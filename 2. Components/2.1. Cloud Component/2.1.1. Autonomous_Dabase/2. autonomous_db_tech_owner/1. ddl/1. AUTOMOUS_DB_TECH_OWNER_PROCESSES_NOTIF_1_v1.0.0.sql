--AUTONOMOUS_DB_TECH_OWNER_PROCESSES_NOTIF_1_v1.0.0
--"PROCESSES NOTIF TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DB_TECH_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDB';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DB_TECH_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

--DELETE TABLE PROCESSES_NOTIF IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_TECH_OWNER'
AND table_name = 'PROCESSES_NOTIF'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_tech_owner.processes_notif CASCADE CONSTRAINTS';
END IF;
--CREATE PROCESSES_NOTIF TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_tech_owner.processes_notif (

          process_id           VARCHAR2(200) PRIMARY KEY,
          process_name         VARCHAR2(100) NOT NULL,
          process_date         VARCHAR2(10) NOT NULL,
          process_type         VARCHAR2(30) NOT NULL,
          start_timestamp      TIMESTAMP NOT NULL,
          end_timestamp        TIMESTAMP NOT NULL,
          status               VARCHAR2(10) NOT NULL CHECK (status IN ('IN_PROGRESS','ERROR','DONE')),
          error_message        VARCHAR2(250),
          admin_user           VARCHAR2(50) NOT NULL,

          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env'))
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_TECH_OWNER'
AND table_name = 'PROCESSES_NOTIF'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PROCESSES_NOTIF table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PROCESSES_NOTIF table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_tech_owner.processes_notif IS ''The table contains the informations about processes that bring data into this schema.''';
-- BUSINESS COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.process_id IS ''The id of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.process_name IS ''The name of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.process_date IS ''The date when the process was started.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.process_type IS ''The type of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.start_timestamp IS ''The start time of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.end_timestamp IS ''The end time of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.status IS ''The status of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.error_message IS ''The error message of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.admin_user IS ''The user who start the process.''';
-- TECHNICAL COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_notif.source_system IS ''Technical Column - The source system of the record''';

--CREATE SEQUENCE SEQ_PROCESSES_NOTIF_PK FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_PROCESSES_NOTIF_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_tech_owner.seq_processes_notif_pk';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_processes_notif_pk
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_PROCESSES_NOTIF_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_PROCESSES_NOTIF_PK sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The SEQ_PROCESSES_NOTIF_PK sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'trg_processes_notif_pk';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_tech_owner.trg_processes_notif_pk';
END IF;
--CREATE TRIGGER
v_sql := q'[
CREATE OR REPLACE TRIGGER trg_processes_notif_pk
BEFORE INSERT ON autonomous_db_tech_owner.processes_notif
FOR EACH ROW
BEGIN
   IF :NEW.process_id IS NULL OR TRIM(:NEW.process_id) = '' THEN
      SELECT TO_CHAR(seq_processes_notif_pk.NEXTVAL)
      INTO :NEW.process_id
      FROM dual;
   END IF;
END;
]';
      
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_PROCESSES_NOTIF_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_PROCESSES_NOTIF_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_PROCESSES_NOTIF_PK trigger for primary key was created.');

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_PROCESSES_NOTIF_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_tech_owner.trg_processes_notif_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_processes_notif_tech_col
            BEFORE INSERT ON autonomous_db_tech_owner.processes_notif
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
                    :NEW.created_by := USER;
                    :NEW.creation_date := CURRENT_TIMESTAMP;
                 END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_PROCESSES_NOTIF_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_PROCESSES_NOTIF_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[6.] The TRG_PROCESSES_NOTIF_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
