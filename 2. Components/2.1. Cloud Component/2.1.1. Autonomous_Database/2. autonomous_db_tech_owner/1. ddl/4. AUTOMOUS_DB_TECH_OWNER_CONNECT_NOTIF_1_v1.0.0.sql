--AUTONOMOUS_DB_TECH_OWNER_CONNECT_NOTIF_1_v1.0.0
--"CONNECT_NOTIF TABLE"
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

--DELETE TABLE CONNECT_NOTIF IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_TECH_OWNER'
AND table_name = 'CONNECT_NOTIF'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_tech_owner.connect_notif CASCADE CONSTRAINTS';
END IF;
--CREATE CONNECT_NOTIF TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_tech_owner.connect_notif (
          conn_key              VARCHAR2(200) PRIMARY KEY,
          user_name	            VARCHAR2(100),
          start_conn_timestamp	TIMESTAMP,
          end_conn_timestamp	TIMESTAMP,
          schema	            VARCHAR2(50),
          user_ip	            VARCHAR2(50),
          action	            VARCHAR2(10),

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
AND table_name = 'CONNECT_NOTIF'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The CONNECT_NOTIF table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The CONNECT_NOTIF table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_tech_owner.CONNECT_notif IS ''The table contains information about the users that connects to the database.''';
-- BUSINESS COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.conn_key IS ''The audit id of the connection.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.user_name IS ''The user name of the connection.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.start_conn_timestamp IS ''The start timestamp of the connection.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.end_conn_timestamp IS ''The end timestamp of the connection.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.schema IS ''The schema where the user enter.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.user_ip IS ''The ip of the user.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.action IS ''The action of the user.''';
-- TECHNICAL COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.CONNECT_notif.source_system IS ''Technical Column - The source system of the record''';

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_CONNECT_NOTIF_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_tech_owner.trg_CONNECT_notif_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_CONNECT_notif_tech_col
            BEFORE INSERT ON autonomous_db_tech_owner.CONNECT_notif
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
WHERE trigger_name = 'TRG_CONNECT_NOTIF_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_CONNECT_NOTIF_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_CONNECT_NOTIF_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[5.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
