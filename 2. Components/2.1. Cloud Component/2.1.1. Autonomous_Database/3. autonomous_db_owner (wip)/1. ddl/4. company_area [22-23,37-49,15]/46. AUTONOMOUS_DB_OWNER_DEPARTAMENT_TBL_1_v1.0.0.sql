--AUTONOMOUS_DB_OWNER_DEPARTMENT_TBL_1_v1.0.0
--"DEPARTMENT TABLE"
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

--DELETE TABLE department IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'DEPARTMENT'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.department CASCADE CONSTRAINTS';
END IF;
--CREATE DEPARTMENT TABLE;
v_sql := q'[
        CREATE TABLE autonomous_db_owner.department (

          --business columns
          department_id NUMBER(38,0) PRIMARY KEY,
          description VARCHAR2(100) NOT NULL,
          annual_budget NUMBER(15,0) NOT NULL,
          operational_costs NUMBER(15,0) NOT NULL,
          expenses NUMBER(15,2) NOT NULL,
          revenue_generated NUMBER(15,2) NOT NULL,
          no_employees NUMBER(15,0) NOT NULL,
          avg_salary NUMBER(15,2) NOT NULL,
          growth_potential NUMBER(5,2) NOT NULL,
          training_budget NUMBER(15,2) NOT NULL,
          no_open_positions NUMBER(10,0),
          turnover_rate NUMBER(5,2) NOT NULL,
          rating NUMBER(5,2) GENERATED ALWAYS AS ( 
LEAST(GREATEST(ROUND(( 
                            /* 20% eficiență bugetară */ 
0.20 * NVL(1 - (operational_costs / NULLIF(annual_budget, 0)), 0) + 
       /* 20% randament financiar */ 
0.20 * NVL(revenue_generated / NULLIF(expenses, 0), 0) + 
         /* 10% cost mediu per angajat (inversat) */ 
0.10 * NVL(1 - (avg_salary / 10000), 0) + 
              /* 15% potențial de creștere */ 
0.15 * NVL(growth_potential / 100, 0) + 
          /* 10% investiție în training */ 
0.10 * NVL(training_budget / NULLIF(annual_budget, 0), 0) + 
           /* 10% poziții deschise vs angajați */ 
0.10 * NVL(1 - (no_open_positions / NULLIF(no_employees, 0)), 0) + 
           /* 15% retenție (invers turnover) */ 
0.15 * NVL(1 - (turnover_rate / 100), 0) ) * 100, 2), 0), 100) 
) VIRTUAL,

          company_id NUMBER(38,0) NOT NULL,
          department_type_code NUMBER(38,0) NOT NULL,
          
          --technical columns
          creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          created_by            VARCHAR2(50) NOT NULL,
          last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          last_updated_by       VARCHAR2(50) NOT NULL,
          source_system         VARCHAR2(20) DEFAULT 'db_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env')),
          sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL CHECK (sync_status IN ('synced','not_synced')),
          sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
          last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          deleted_flag          VARCHAR2(1) DEFAULT 'N' NOT NULL CHECK (deleted_flag IN ('N','Y')), 

          CONSTRAINT fk_company_id FOREIGN KEY (company_id) REFERENCES company (company_id),
          CONSTRAINT fk_department_type_code FOREIGN KEY (department_type_code) REFERENCES department_type (department_type_id)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_db_owner.department TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'DEPARTMENT'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The DEPARTMENT table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The DEPARTMENT table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.department IS ''The table contains all the informations about the companies from application. Some posibile values like BCR,Thales, Ubisoft,etc''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.department_id IS ''The id of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.description IS ''The description of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.annual_budget IS ''The annual budget of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.operational_costs IS ''The operational costs of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.expenses IS ''The expenses of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.revenue_generated IS ''The revenue generated of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.no_employees IS ''The employees number of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.avg_salary IS ''The average salary of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.growth_potential IS ''The growth potential of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.training_budget IS ''The training budget of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.no_open_positions IS ''The number of open positions from the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.turnover_rate IS ''The turnover rate from the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.rating IS ''The rating of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.company_id IS ''The id of the company which contains the depertment''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.department_type_code IS ''The code of the depertment type''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.department.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_DEPARTMENT_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_DEPARTMENT_ID';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.seq_department_id';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_department_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_DEPARTMENT_ID';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_DEPARTMENT_ID sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_DEPARTMENT_ID sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DEPARTMENT_ID_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_department_id_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_department_id_pk
          BEFORE INSERT ON autonomous_db_owner.department
          FOR EACH ROW
          WHEN (NEW.department_id IS NULL)
          BEGIN
             SELECT seq_department_id.NEXTVAL INTO :NEW.department_id FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DEPARTMENT_ID_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DEPARTMENT_ID_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_DEPARTMENT_ID_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DEPARTMENT_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_department_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_department_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.department
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
--CHECK IF THE TRIGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_DEPARTMENT_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_DEPARTMENT_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_DEPARTMENT_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/