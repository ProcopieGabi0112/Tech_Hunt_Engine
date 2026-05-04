--AUTONOMOUS_DB_OWNER_JOB_TBL_1_v1.0.0
--"JOB TABLE"
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

--DELETE TABLE JOB IF EXIST;
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'JOB'
AND tablespace_name = 'DATA';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE autonomous_db_owner.job CASCADE CONSTRAINTS';
END IF;
--CREATE DEPARTMENT TABLE;
employees_rating
v_sql := q'[
        CREATE TABLE autonomous_db_owner.job (

          --business columns
          job_id NUMBER(38,0) PRIMARY KEY,
          description VARCHAR2(200) NOT NULL,
          requirements VARCHAR2(500) NOT NULL,
          responsabilities VARCHAR2(300) NOT NULL,
          benefits VARCHAR2(300),
          salary_min NUMBER(15,0) NOT NULL,
          salary_max NUMBER(15,0),
          hire_date DATE NOT NULL, 
          expiry_date DATE, 
          employment_period NUMBER(10,0),
          demand_score NUMBER(5,2) NOT NULL,


          complexity_score NUMBER(5,2) DEFAULT 0 NOT NULL,
-- Coloana complexity_rating se va calcula pe baza mai multor variabile. tabelele nomenclatoare asociate acestei tabele va trebui sa afisam un complexity_score pe baza tuturor valorilor pentru fiecare valoare pentru ca fiecare valoare din nomenclatoare are o complexitate diferita de exemplu cum Data Analyst este mai slab decat Data Engineer ca si idee. Pentru coloana asta as vrea sa facem o formula bazata pe valorile din nomenclatoare + un count pe numarul de skill-uri dorite. CREATE OR REPLACE TRIGGER trg_job_complexity_score BEFORE INSERT OR UPDATE ON JOB FOR EACH ROW DECLARE v_skill_score NUMBER := 0; v_category_score NUMBER := 0; v_title_score NUMBER := 0; v_level_score NUMBER := 0; v_employment_score NUMBER := 0; v_work_type_score NUMBER := 0; BEGIN -------------------------------------------------------------------- -- 1. SKILL SCORE (fallback complet la 0) -------------------------------------------------------------------- SELECT NVL(SUM(ts.rating * js.importance_weight * js.required_level) / NULLIF(COUNT(*), 0), 0) INTO v_skill_score FROM JOB_SKILL js JOIN TECHNOLOGY_SKILL ts ON ts.technology_skill_code = js.technology_skill_code WHERE js.job_id = :NEW.job_id; -------------------------------------------------------------------- -- 2. NOMENCLATOARE (fiecare cu fallback la 0 dacă FK este NULL) -------------------------------------------------------------------- -- JOB_CATEGORY IF :NEW.job_category_id IS NOT NULL THEN SELECT NVL(complexity_score, 0) INTO v_category_score FROM JOB_CATEGORY WHERE job_category_id = :NEW.job_category_id; ELSE v_category_score := 0; END IF; -- JOB_TITLE IF :NEW.job_title_id IS NOT NULL THEN SELECT NVL(complexity_score, 0) INTO v_title_score FROM JOB_TITLE WHERE job_title_id = :NEW.job_title_id; ELSE v_title_score := 0; END IF; -- JOB_LEVEL IF :NEW.job_level_id IS NOT NULL THEN SELECT NVL(complexity_score, 0) INTO v_level_score FROM JOB_LEVEL WHERE job_level_id = :NEW.job_level_id; ELSE v_level_score := 0; END IF; -- EMPLOYMENT_TYPE IF :NEW.employment_type_id IS NOT NULL THEN SELECT NVL(complexity_score, 0) INTO v_employment_score FROM EMPLOYMENT_TYPE WHERE employment_type_id = :NEW.employment_type_id; ELSE v_employment_score := 0; END IF; -- WORK_TYPE IF :NEW.work_type_id IS NOT NULL THEN SELECT NVL(complexity_score, 0) INTO v_work_type_score FROM WORK_TYPE WHERE work_type_id = :NEW.work_type_id; ELSE v_work_type_score := 0; END IF; -------------------------------------------------------------------- -- 3. FORMULA FINALĂ (50% skill + 50% nomenclatoare) -------------------------------------------------------------------- :NEW.complexity_score := ROUND( 0.5 * v_skill_score + 0.2 * v_category_score + 0.15 * v_title_score + 0.05 * v_level_score + 0.05 * v_employment_score + 0.05 * v_work_type_score, 2 ); END; /
          
          
          employees_rating NUMBER(5,2) DEFAULT 0 NOT NULL,
-- Coloana employees_rating se va calcula pe baza mediei obtinute din tabela rating folosind un trigger pe insert/update pe tabela

          job_status VARCHAR2(50) NOT NULL, -- DEFAULT: ''DRAFT''
          department_id NUMBER(38,0) NOT NULL,
          employment_type_id NUMBER(25,0) NOT NULL,
          work_type_id NUMBER(25,0) NOT NULL,
          job_title_id NUMBER(25,0) NOT NULL,
          job_level_id NUMBER(25,0) NOT NULL,
          job_category_id NUMBER(25,0) NOT NULL,
          currency_code NUMBER(38,0) NOT NULL,
          location_id NUMBER(38,0) NOT NULL,
          
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

          CONSTRAINT fk_department_id FOREIGN KEY (department_id) REFERENCES department (department_id),
          CONSTRAINT fk_employment_type_id FOREIGN KEY (employment_type_id ) REFERENCES employment_type (employment_type_id),
          CONSTRAINT fk_work_type_id FOREIGN KEY (work_type_id) REFERENCES work_type (work_type_id),
          CONSTRAINT fk_job_title_id FOREIGN KEY (job_title_id) REFERENCES job_title (job_title_id),
          CONSTRAINT fk_job_level_id FOREIGN KEY (job_level_id) REFERENCES job_level (job_level_id),
          CONSTRAINT fk_job_category_id FOREIGN KEY (job_category_id) REFERENCES job_category (job_category_id),
          CONSTRAINT fk_currency_code FOREIGN KEY (currency_code) REFERENCES currency (currency_code),
          CONSTRAINT fk_location_id FOREIGN KEY (location_id) REFERENCES location (location_id)
        )
    ]';
 
EXECUTE IMMEDIATE v_sql;
EXECUTE IMMEDIATE 'GRANT SELECT ON autonomous_db_owner.job TO autonomous_db_out_owner';
--[1.] VERIFY IF THE TABLE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM all_tables
WHERE owner = 'AUTONOMOUS_DB_OWNER'
AND table_name = 'JOB'
AND tablespace_name = 'DATA';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The JOB table wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[2.] The JOB table was created.');
--CREATE COMMENTS FOR TABLE AND COLUMNS
-- TABLE COMMENT
EXECUTE IMMEDIATE 'COMMENT ON TABLE autonomous_db_owner.job IS ''The table contains all the informations about the companies from application. Some posibile values like BCR,Thales, Ubisoft,etc''';

-- COLUMNS COMMENT
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.job_id IS ''The id of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.description IS ''The description of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.requirements IS ''The requirements of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.responsabilities IS ''The responsabilities of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.benefits IS ''The benefits of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.salary_min IS ''The minimum salary of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.salary_max IS ''The maximum salary of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.hire_date IS ''The hire date of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.expire_date IS ''The expire date of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.demand_score IS ''The demand score of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.complexity_score IS ''The complexity score of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.employees_rating IS ''The employees rating from the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.job_status IS ''The status of the job''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.department_id IS ''The id of the department''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.employment_type_id IS ''The id of the employment type''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.work_type_id IS ''The id of the work type''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.job_title_id IS ''The id of the job title''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.job_level_id IS ''The id of the job level''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.job_category_id IS ''The id of the job category''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.currency_code IS ''The currency code of the salary''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.location_id IS ''The location id of the job''';

EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.creation_date IS ''Technical Column - The creation date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.created_by IS ''Technical Column - The user who created the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.last_update_date IS ''Technical Column - The last update date of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.last_updated_by IS ''Technical Column - The user who updated the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.source_system IS ''Technical Column - The source system of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.sync_status IS ''Technical Column - The sync status of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.sync_version IS ''Technical Column - The sync version of the record''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.last_synced_at IS ''Technical Column - The date when the record was last time synced''';
EXECUTE IMMEDIATE 'COMMENT ON COLUMN autonomous_db_owner.job.deleted_flag IS ''Technical Column - The flag indicating if the record is deleted or not''';

--CREATE SEQUENCE SEQ_JOB_ID FOR PRIMARY KEY
--DELETE SEQUENCE IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_JOB_ID';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE autonomous_db_owner.seq_job_id';
END IF;
--CREATE SEQUENCE
 EXECUTE IMMEDIATE '
    CREATE SEQUENCE seq_job_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
  ';
SELECT COUNT(*) INTO v_count
FROM user_sequences
WHERE sequence_name = 'SEQ_JOB_ID';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The SEQ_JOB_ID sequence wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The SEQ_JOB_ID sequence for primary key was created.');

--CREATE TRIGGER FOR PRIMARY KEY;
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_JOB_ID_PK';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_job_id_pk';
END IF;
--CREATE TRIGGER
v_sql := 'CREATE OR REPLACE TRIGGER trg_job_id_pk
          BEFORE INSERT ON autonomous_db_owner.job
          FOR EACH ROW
          WHEN (NEW.job_id IS NULL)
          BEGIN
             SELECT seq_job_id.NEXTVAL INTO :NEW.job_id FROM dual;
          END;';          
EXECUTE IMMEDIATE v_sql;
--CHECK IG THE TRiGGER WAS CREATED;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_JOB_ID_PK';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_JOB_ID_PK trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[4.] The TRG_JOB_ID_PK trigger for primary key was created.');
--CREATE TRIGGER FOR TECHNICAL COLUMNS
--DELETE TRIGGER IF EXISTS;
SELECT COUNT(*) INTO v_count
FROM user_triggers
WHERE trigger_name = 'TRG_JOB_TECH_COL';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER autonomous_db_owner.trg_job_tech_col';
END IF;
--CREATE TRIGGER
v_sql := '  CREATE OR REPLACE TRIGGER trg_job_tech_col
            BEFORE INSERT OR UPDATE ON autonomous_db_owner.job
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
WHERE trigger_name = 'TRG_JOB_TECH_COL';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The TRG_JOB_TECH_COL trigger wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The TRG_JOB_TECH_COL trigger for technical columns was created.');

DBMS_OUTPUT.PUT_LINE('[6.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/