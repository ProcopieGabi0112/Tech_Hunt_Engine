--AUTONOMOUS_DW_TECH_OWNER_DWH_COMMANDS_NOTIF_1_v1.0.0
--"DWH_COMMANDS_NOTIF TABLE"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'AUTONOMOUS_DW_TECH_OWNER'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "AUTONOMOUS_DW_TECH_OWNER"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDW"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDW)"

--DELETE TABLE COMMANDS_NOTIF IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_TECH_OWNER'
AND table_name = 'DWH_COMMANDS_NOTIF'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_dw_tech_owner.dwh_commands_notif CASCADE CONSTRAINTS';
END IF;
--CREATE COMMANDS_NOTIF TABLE;
v_sql := q'[
        CREATE TABLE autonomous_dw_tech_owner.dwh_commands_notif (
          comm_key              VARCHAR2(200) PRIMARY KEY,
          user_name	            VARCHAR2(100) NOT NULL,
          command_timestamp	    TIMESTAMP NOT NULL,
          sql_command           VARCHAR2(4000) NOT NULL,
          command_type	        VARCHAR2(30) NOT NULL,
          schema	              VARCHAR2(50) NOT NULL,
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL, 
          source_system         VARCHAR2(20) DEFAULT 'dw_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env'))
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DW_TECH_OWNER'
AND table_name = 'DWH_COMMANDS_NOTIF'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DWH_COMMANDS_NOTIF table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The DWH_COMMANDS_NOTIF table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_dw_tech_owner.dwh_commands_notif IS ''The table contains information about all the commands that was released by the users connected to the database.''';
-- BUSINESS COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.comm_key IS ''The audit id of the command.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.user_name IS ''The user name of the command.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.command_timestamp IS ''The timestamp of the command.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.sql_command IS ''The description of the command''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.command_type IS ''The type of the command.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.schema IS ''The schema where the command was released.''';
-- TECHNICAL COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_dw_tech_owner.dwh_commands_notif.source_system IS ''Technical Column - The source system of the record''';

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DWH_COMMANDS_NOTIF_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_dw_tech_owner.trg_dwh_commands_notif_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_dwh_commands_notif_tech_col
            BEFORE INSERT ON autonomous_dw_tech_owner.dwh_commands_notif
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
WHERE trigger_name = 'TRG_DWH_COMMANDS_NOTIF_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DWH_COMMANDS_NOTIF_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_DWH_COMMANDS_NOTIF_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[5.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
