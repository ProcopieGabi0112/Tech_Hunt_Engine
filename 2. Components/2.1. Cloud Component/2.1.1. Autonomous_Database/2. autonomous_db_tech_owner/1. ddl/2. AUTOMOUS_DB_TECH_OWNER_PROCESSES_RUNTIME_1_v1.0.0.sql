--AUTONOMOUS_DB_TECH_OWNER_PROCESSES_RUNTIME_1_v1.0.0
--"PROCESSES RUNTIME TABLE"
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

--DELETE TABLE PROCESSES_RUNTIME IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_TECH_OWNER'
AND table_name = 'PROCESSES_RUNTIME'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_tech_owner.processes_runtime CASCADE CONSTRAINTS';
END IF;
--CREATE PROCESSES_RUNTIME TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_tech_owner.processes_runtime (
          process_code NUMBER(38,0) PRIMARY KEY,
          process_name VARCHAR2(200) NOT NULL,
          process_type VARCHAR2(30) NOT NULL CHECK (process_type IN ('GROUP','PROCESS','JOB')),
          parent_process NUMBER(38,0),
          execution_mode VARCHAR2(20) DEFAULT 'SEQUENTIAL' NOT NULL CHECK (execution_mode IN ('PARALLEL','SEQUENTIAL')),
          run_order NUMBER(38,0) NOT NULL,
          frequency VARCHAR2(50),
          start_condition VARCHAR2(2000),
          expected_rows NUMBER(5,0),
          waiting_time NUMBER(15,0),
          retry_time NUMBER(15,0),
          is_active  VARCHAR2(1) DEFAULT 'Y' NOT NULL CHECK (is_active IN ('Y','N')),
          job_name  VARCHAR2(200),
          chain_name  VARCHAR2(200),
          program_name VARCHAR2(200),
          description VARCHAR2(500),

          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL, 
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL, 
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          CONSTRAINT fk_parent_process FOREIGN KEY (parent_process) REFERENCES processes_runtime(process_code)
        )
    ]';
EXECUTE IMMEDIATE v_sql;
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_TECH_OWNER'
AND table_name = 'PROCESSES_RUNTIME'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PROCESSES_RUNTIME table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PROCESSES_RUNTIME table was created.');
--CREATE COMMENTS FROM TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_tech_owner.processes_runtime IS ''The table contains the information about the processes that will move data through database.''';
-- BUSINESS COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.process_code IS ''The code of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.process_name IS ''The name of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.process_type IS ''The type of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.parent_process IS ''The code of the parent process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.execution_mode IS ''The execution mode of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.run_order IS ''The run order of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.start_time IS ''The start time of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.start_condition IS ''The start condition of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.expected_rows IS ''The expected rows from the start condition of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.waiting_time IS ''The number of seconds that the process wait to start condition to complete.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.retry_time IS ''The number of the seconds that the process retry to see if the start condition was completed.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.is_active IS ''The flag that indicating if the process is active or not.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.job_name IS ''The job name of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.chain_name IS ''The chain name of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.program_name IS ''The program name of the process.''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.description IS ''The description of the process.''';
-- TECHNICAL COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_tech_owner.processes_runtime.source_system IS ''Technical Column - The source system of the record''';

--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_PROCESSES_RUNTIME_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_tech_owner.trg_processes_runtime_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_processes_runtime_tech_col
            BEFORE INSERT ON autonomous_db_tech_owner.processes_runtime
            FOR EACH ROW
            BEGIN
                 IF INSERTING THEN
                    :NEW.created_by := USER;
                    :NEW.creation_date := CURRENT_TIMESTAMP;
                    :NEW.last_updated_by := USER;
                 END IF;
                 IF UPDATING THEN
                    :NEW.last_updated_by := USER;
                    :NEW.last_update_date := CURRENT_TIMESTAMP;
                 END IF;
            END;';
EXECUTE IMMEDIATE v_sql;
--CHECK IF THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_PROCESSES_RUNTIME_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_PROCESSES_RUNTIME_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_PROCESSES_RUNTIME_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[5.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

