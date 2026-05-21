--AUTONOMOUS_DW_OWNER_DWH_JOB_DIM_JOB_1_v1.0.0
--"DWH_JOB_DIM JOB"
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
WHERE sys_context('USERENV', 'SESSION_USER') = 'ADMIN'
AND sys_context('USERENV', 'CON_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW' 
AND sys_context('USERENV', 'DB_NAME') = 'G90CE4847B77DFA_TECHHUNTENGINEDW';
IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The environment is wrong. Please check the user.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('[2.] The environment is preparing...');
-- Current_User: "ADMIN"	
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDW"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDW"
-- Database_Type: "Pluggable Database (PDB)"

-- CREATE IL PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_JOB_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_job_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'~
             CREATE OR REPLACE PROCEDURE prc_etl_job_initial_load
             AS
                v_count             NUMBER;
                v_notification_id   VARCHAR2(200);
                v_error             VARCHAR2(4000);
             BEGIN
    ------------------------------------------ 
    -- [1.] INSERT NOTIFICATION (IN_PROGRESS)
    ------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_JOB_INITIAL_LOAD_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'INITIAL LOAD',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
     RETURNING notification_id INTO v_notification_id;
     COMMIT;
    ------------------------------------ 
    -- [2.] VALIDATE SOURCE TABLES SYNC
    ------------------------------------
 
    SELECT COUNT(*) INTO v_count
    FROM dual
      WHERE EXISTS ( SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_department
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_department_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_employment_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_work_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_job_category
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_job_title
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_job_level
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_currency
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_COMPANY_INITIAL_LOAD_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'INITIAL LOAD'
                   AND status = 'DONE'
                  );
                    
    IF v_count = 0 THEN
        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = 'Source tables not synced today'
        WHERE notification_id = v_notification_id;
        COMMIT;
        RETURN;
    END IF;

    ------------------------- 
    -- [4.] MERGE DIM TABLE
    -------------------------

    MERGE INTO autonomous_dw_owner.dwh_job_dim d
    USING (
         SELECT DISTINCT
                j.job_id AS job_id,
                j.creation_date AS publish_date,
                j.hire_date AS hire_date,
                j.expiry_date AS expiry_date,
                j.employment_period AS employment_period,
                j.salary_min AS salary_min,
                j.salary_max AS salary_max,
                cur.currency_code AS currency_code,
                cur.name AS currency_name,
                j.demand_score AS demand_score,
                j.complexity_score AS complexity_score,
                j.job_status AS job_status,
                (
    SELECT '[' ||
           LISTAGG(
             '{ "lang": "' || lang.name ||
             '", "level": "' || lr.nivel ||
             '", "importance": "' || lr.importance ||
             '", "lang_rating": ' || lang.rating ||
             ', "cert_rating": ' || lvl.rating ||
             ' }',
             ','
           ) WITHIN GROUP (ORDER BY lr.priority)
           || ']'
    FROM autonomous_dw_landing_owner.dwh_language_requirement lr
    JOIN autonomous_dw_landing_owner.dwh_language lang
      ON lr.lang_code = lang.lang_code
    JOIN autonomous_dw_landing_owner.dwh_lang_level lvl
      ON lr.lang_level_id = lvl.lang_level_id
    WHERE lr.job_id = j.job_id
      AND lr.deleted_flag = 'N'
) language_requirement,
                ( /* CERTIFICATIONS SCORE */
                     SELECT AVG( (lang.rating + lvl.rating) / 2 )
                     FROM autonomous_dw_landing_owner.dwh_language_requirement lr
                     JOIN autonomous_dw_landing_owner.dwh_language lang
                       ON lr.lang_code = lang.lang_code
                     JOIN autonomous_dw_landing_owner.dwh_lang_level lvl
                       ON lr.lang_level_id = lvl.lang_level_id
                     WHERE lr.job_id = j.job_id
                       AND lr.deleted_flag = 'N'
                ) AS certifications_score,
                (  /* DEGREE REQUIREMENTS AS JSON ARRAY */
                      SELECT '[' ||
                             LISTAGG(
                               '{ "degree_type": "' || dr.degree_type ||
                               '", "importance": "' || dr.importance ||
                               '", "specialization": "' || spec.name ||
                               '", "institution": "' || inst.name ||
                               '", "spec_rating": ' || spec.rating ||
                               ', "inst_rating": ' || inst.rating ||
                               ' }', ','
                             ) WITHIN GROUP (ORDER BY dr.priority)
                             || ']'
                      FROM autonomous_dw_landing_owner.dwh_degree_requirement dr
                      JOIN autonomous_dw_landing_owner.dwh_specialization spec
                        ON dr.specialization_type_code = spec.specialization_type_id
                      JOIN autonomous_dw_landing_owner.dwh_institution inst
                        ON dr.institution_id = inst.institution_id
                      WHERE dr.job_id = j.job_id
                        AND dr.deleted_flag = 'N'
                ) AS degree_requirement,
                ( /* ACADEMIC SCORE */
                     SELECT AVG( (spec.rating + inst.rating) / 2 )
                     FROM autonomous_dw_landing_owner.dwh_degree_requirement dr
                     JOIN autonomous_dw_landing_owner.dwh_specialization spec
                       ON dr.specialization_type_code = spec.specialization_type_id
                     JOIN autonomous_dw_landing_owner.dwh_institution inst
                       ON dr.institution_id = inst.institution_id
                     WHERE dr.job_id = j.job_id
                       AND dr.deleted_flag = 'N'
                ) AS academic_score,
                et.employment_type_id,                                /* EMPLOYMENT TYPE */
                et.name AS employment_type_name,
                et.complexity_score AS employment_type_score,
                wt.work_type_id,                                        /* WORK TYPE */
                wt.name AS work_type_name,
                wt.complexity_score AS work_type_score,
                jc.job_category_id,                                    /* JOB CATEGORY */
                jc.name AS job_category_name,
                jc.complexity_score AS job_category_score,
                jt.job_title_id,                                        /* JOB TITLE */
                jt.name AS job_title_name,
                jt.complexity_score AS job_title_score,
                jl.job_level_id AS job_level_id,                      /* JOB LEVEL */
                jl.name AS job_level_name,
                jl.complexity_score AS job_level_score,
                dep.department_id,                                     /* DEPARTMENT */
                dep_type.name AS department_type_name,
                dep.rating AS department_rating,
                comp.company_key,                           /* COMPANY (JOINED THROUGH DEPARTMENT) */
                loc.job_location_key                        /* LOCATION (JOINED THROUGH NATURAL KEY) */
         FROM autonomous_dw_landing_owner.dwh_job j
              JOIN autonomous_dw_landing_owner.dwh_department dep ON j.department_id = dep.department_id 
              JOIN autonomous_dw_owner.dwh_company_dim comp ON dep.company_id = comp.company_id
              JOIN autonomous_dw_owner.dwh_job_location_dim loc ON j.location_id = loc.location_address_code
              JOIN autonomous_dw_landing_owner.dwh_employment_type et ON j.employment_type_id = et.employment_type_id
              JOIN autonomous_dw_landing_owner.dwh_work_type wt ON j.work_type_id = wt.work_type_id
              JOIN autonomous_dw_landing_owner.dwh_job_category jc ON j.job_category_id = jc.job_category_id
              JOIN autonomous_dw_landing_owner.dwh_job_title jt ON j.job_title_id = jt.job_title_id
              JOIN autonomous_dw_landing_owner.dwh_job_level jl ON j.job_level_id = jl.job_level_id
              JOIN autonomous_dw_landing_owner.dwh_department_type dep_type ON dep.department_type_code = dep_type.department_type_id
              JOIN autonomous_dw_landing_owner.dwh_currency cur ON j.currency_code = cur.currency_code
         WHERE j.deleted_flag = 'N'

          ) s
    ON (d.job_id = s.job_id)
    WHEN MATCHED THEN UPDATE SET
          
    d.publish_date              = s.publish_date,
    d.hire_date                 = s.hire_date,
    d.expiry_date               = s.expiry_date,
    d.employment_period         = s.employment_period,
    d.salary_min                = s.salary_min,
    d.salary_max                = s.salary_max,
    d.currency_code             = s.currency_code,
    d.currency_name             = s.currency_name,
    d.demand_score              = s.demand_score,
    d.complexity_score          = s.complexity_score,
    d.job_status                = s.job_status,
    d.language_requirement      = s.language_requirement,
    d.certifications_score      = s.certifications_score,
    d.degree_requirement        = s.degree_requirement,
    d.academic_score            = s.academic_score,
    d.employment_type_id        = s.employment_type_id,
    d.employment_type_name      = s.employment_type_name,
    d.employment_type_score     = s.employment_type_score,
    d.work_type_id              = s.work_type_id,
    d.work_type_name            = s.work_type_name,
    d.work_type_score           = s.work_type_score,
    d.job_category_id           = s.job_category_id,
    d.job_category_name         = s.job_category_name,
    d.job_category_score        = s.job_category_score,
    d.job_title_id              = s.job_title_id,
    d.job_title_name            = s.job_title_name,
    d.job_title_score           = s.job_title_score,
    d.job_level_id              = s.job_level_id,
    d.job_level_name            = s.job_level_name,
    d.job_level_score           = s.job_level_score,
    d.department_id             = s.department_id,
    d.department_type_name      = s.department_type_name,
    d.department_rating         = s.department_rating,
    d.company_key               = s.company_key,
    d.job_location_key          = s.job_location_key,
    d.deleted_flag              = 'N',
    d.last_update_date          = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (
 
              job_id,
              publish_date,
              hire_date,
              expiry_date,
              employment_period,
              salary_min,
              salary_max,
              currency_code,
              currency_name,
              demand_score,
              complexity_score,
              job_status,
              language_requirement,
              certifications_score,
              degree_requirement,
              academic_score,
              employment_type_id,
              employment_type_name,
              employment_type_score,
              work_type_id,
              work_type_name,
              work_type_score,
              job_category_id,
              job_category_name,
              job_category_score,
              job_title_id,
              job_title_name,
              job_title_score,
              job_level_id,
              job_level_name,
              job_level_score,
              department_id,
              department_type_name,
              department_rating,
              company_key,
              job_location_key,
              deleted_flag,
              creation_date,
              last_update_date
)
VALUES (
     
              s.job_id,
              s.publish_date,
              s.hire_date,
              s.expiry_date,
              s.employment_period,
              s.salary_min,
              s.salary_max,
              s.currency_code,
              s.currency_name,
              s.demand_score,
              s.complexity_score,
              s.job_status,
              s.language_requirement,
              s.certifications_score,
              s.degree_requirement,
              s.academic_score,
              s.employment_type_id,
              s.employment_type_name,
              s.employment_type_score,
              s.work_type_id,
              s.work_type_name,
              s.work_type_score,
              s.job_category_id,
              s.job_category_name,
              s.job_category_score,
              s.job_title_id,
              s.job_title_name,
              s.job_title_score,
              s.job_level_id,
              s.job_level_name,
              s.job_level_score,
              s.department_id,
              s.department_type_name,
              s.department_rating,
              s.company_key,
              s.job_location_key,
              'N',
              CURRENT_TIMESTAMP,
              CURRENT_TIMESTAMP
);
    COMMIT;

---------------------------------------------------------------------- 
-- [5.] SUCCESS NOTIFICATION
----------------------------------------------------------------------

    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'DONE',
        end_timestamp = CURRENT_TIMESTAMP
    WHERE notification_id = v_notification_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;

        v_error := SQLERRM;

        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = v_error
        WHERE notification_id = v_notification_id;

        COMMIT;

        RAISE_APPLICATION_ERROR(-20002, v_error);

END;
 ~';

 EXECUTE IMMEDIATE v_sql;

--[1.] VERIFY IF THE PROCEDURE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_JOB_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_JOB_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_JOB_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_job_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_JOB_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_JOB_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_job_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'~
              CREATE OR REPLACE PROCEDURE prc_etl_job_daily
              AS
                v_count             NUMBER;
                v_notification_id   VARCHAR2(200);
                v_error             VARCHAR2(4000);
             BEGIN
    ------------------------------------------ 
    -- [1.] INSERT NOTIFICATION (IN_PROGRESS)
    ------------------------------------------
    INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
        process_name,
        process_date,
        process_type,
        start_timestamp,
        status,
        admin_user
    )
    VALUES (
        'ETL_JOB_DAILY_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'DAILY',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        'AUTONOMOUS_DW_ADMIN'
    )
     RETURNING notification_id INTO v_notification_id;
     COMMIT;
    ------------------------------------ 
    -- [2.] VALIDATE SOURCE TABLES SYNC
    ------------------------------------
 
SELECT COUNT(*) INTO v_count
    FROM dual
      WHERE EXISTS ( SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_department
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_department_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_employment_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_work_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_job_category
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_job_title
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_job_level
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_currency
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_COMPANY_INITIAL_LOAD_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'INITIAL LOAD'
                   AND status = 'DONE'
                  );
                    
    IF v_count = 0 THEN
        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = 'Source tables not synced today'
        WHERE notification_id = v_notification_id;
        COMMIT;
        RETURN;
    END IF;

    ------------------------- 
    -- [4.] MERGE DIM TABLE
    -------------------------

    MERGE INTO autonomous_dw_owner.dwh_job_dim d
    USING (
         SELECT DISTINCT
                j.job_id AS job_id,
                j.creation_date AS publish_date,
                j.hire_date AS hire_date,
                j.expiry_date AS expiry_date,
                j.employment_period AS employment_period,
                j.salary_min AS salary_min,
                j.salary_max AS salary_max,
                cur.currency_code AS currency_code,
                cur.name AS currency_name,
                j.demand_score AS demand_score,
                j.complexity_score AS complexity_score,
                j.job_status AS job_status,
                (  /* LANGUAGE REQUIREMENTS AS JSON ARRAY */
                      SELECT '[' ||
                             LISTAGG(
                               '{ "lang": "' || lang.name ||
                               '", "level": "' || lr.nivel ||
                               '", "importance": "' || lr.importance ||
                               '", "lang_rating": ' || lang.rating ||
                               ', "cert_rating": ' || lvl.rating ||
                               ' }', ','
                             ) WITHIN GROUP (ORDER BY lr.priority)
                             || ']'
                      FROM autonomous_dw_landing_owner.dwh_language_requirement lr
                      JOIN autonomous_dw_landing_owner.dwh_language lang
                        ON lr.lang_code = lang.lang_code
                      JOIN autonomous_dw_landing_owner.dwh_lang_level lvl
                        ON lr.lang_level_id = lvl.lang_level_id
                      WHERE lr.job_id = j.job_id
                        AND lr.deleted_flag = 'N'
                 ) AS language_requirement,
                ( /* CERTIFICATIONS SCORE */
                     SELECT AVG( (lang.rating + lvl.rating) / 2 )
                     FROM autonomous_dw_landing_owner.dwh_language_requirement lr
                     JOIN autonomous_dw_landing_owner.dwh_language lang
                       ON lr.lang_code = lang.lang_code
                     JOIN autonomous_dw_landing_owner.dwh_lang_level lvl
                       ON lr.lang_level_id = lvl.lang_level_id
                     WHERE lr.job_id = j.job_id
                       AND lr.deleted_flag = 'N'
                ) AS certifications_score,
                (  /* DEGREE REQUIREMENTS AS JSON ARRAY */
                      SELECT '[' ||
                             LISTAGG(
                               '{ "degree_type": "' || dr.degree_type ||
                               '", "importance": "' || dr.importance ||
                               '", "specialization": "' || spec.name ||
                               '", "institution": "' || inst.name ||
                               '", "spec_rating": ' || spec.rating ||
                               ', "inst_rating": ' || inst.rating ||
                               ' }', ','
                             ) WITHIN GROUP (ORDER BY dr.priority)
                             || ']'
                      FROM autonomous_dw_landing_owner.dwh_degree_requirement dr
                      JOIN autonomous_dw_landing_owner.dwh_specialization spec
                        ON dr.specialization_type_code = spec.specialization_type_id
                      JOIN autonomous_dw_landing_owner.dwh_institution inst
                        ON dr.institution_id = inst.institution_id
                      WHERE dr.job_id = j.job_id
                        AND dr.deleted_flag = 'N'
                ) AS degree_requirement,
                ( /* ACADEMIC SCORE */
                     SELECT AVG( (spec.rating + inst.rating) / 2 )
                     FROM autonomous_dw_landing_owner.dwh_degree_requirement dr
                     JOIN autonomous_dw_landing_owner.dwh_specialization spec
                       ON dr.specialization_type_code = spec.specialization_type_id
                     JOIN autonomous_dw_landing_owner.dwh_institution inst
                       ON dr.institution_id = inst.institution_id
                     WHERE dr.job_id = j.job_id
                       AND dr.deleted_flag = 'N'
                ) AS academic_score,
                et.employment_type_id,                                /* EMPLOYMENT TYPE */
                et.name AS employment_type_name,
                et.complexity_score AS employment_type_score,
                wt.work_type_id,                                        /* WORK TYPE */
                wt.name AS work_type_name,
                wt.complexity_score AS work_type_score,
                jc.job_category_id,                                    /* JOB CATEGORY */
                jc.name AS job_category_name,
                jc.complexity_score AS job_category_score,
                jt.job_title_id,                                        /* JOB TITLE */
                jt.name AS job_title_name,
                jt.complexity_score AS job_title_score,
                jl.job_level_id AS job_level_id,                      /* JOB LEVEL */
                jl.name AS job_level_name,
                jl.complexity_score AS job_level_score,
                dep.department_id,                                     /* DEPARTMENT */
                dep_type.name AS department_type_name,
                dep.rating AS department_rating,
                comp.company_key,                           /* COMPANY (JOINED THROUGH DEPARTMENT) */
                loc.job_location_key                        /* LOCATION (JOINED THROUGH NATURAL KEY) */
         FROM autonomous_dw_landing_owner.dwh_job j
              JOIN autonomous_dw_landing_owner.dwh_department dep ON j.department_id = dep.department_id 
              JOIN autonomous_dw_owner.dwh_company_dim comp ON dep.company_id = comp.company_id
              JOIN autonomous_dw_owner.dwh_job_location_dim loc ON j.location_id = loc.location_address_code
              JOIN autonomous_dw_landing_owner.dwh_employment_type et ON j.employment_type_id = et.employment_type_id
              JOIN autonomous_dw_landing_owner.dwh_work_type wt ON j.work_type_id = wt.work_type_id
              JOIN autonomous_dw_landing_owner.dwh_job_category jc ON j.job_category_id = jc.job_category_id
              JOIN autonomous_dw_landing_owner.dwh_job_title jt ON j.job_title_id = jt.job_title_id
              JOIN autonomous_dw_landing_owner.dwh_job_level jl ON j.job_level_id = jl.job_level_id
              JOIN autonomous_dw_landing_owner.dwh_department_type dep_type ON dep.department_type_code = dep_type.department_type_id
              JOIN autonomous_dw_landing_owner.dwh_currency cur ON j.currency_code = cur.currency_code
         WHERE j.deleted_flag = 'N' AND TRUNC(j.last_update_date) = TRUNC(sysdate-1)

          ) s
    ON (d.job_id = s.job_id)
    WHEN MATCHED THEN UPDATE SET
          
    d.publish_date              = s.publish_date,
    d.hire_date                 = s.hire_date,
    d.expiry_date               = s.expiry_date,
    d.employment_period         = s.employment_period,
    d.salary_min                = s.salary_min,
    d.salary_max                = s.salary_max,
    d.currency_code             = s.currency_code,
    d.currency_name             = s.currency_name,
    d.demand_score              = s.demand_score,
    d.complexity_score          = s.complexity_score,
    d.job_status                = s.job_status,
    d.language_requirement      = s.language_requirement,
    d.certifications_score      = s.certifications_score,
    d.degree_requirement        = s.degree_requirement,
    d.academic_score            = s.academic_score,
    d.employment_type_id        = s.employment_type_id,
    d.employment_type_name      = s.employment_type_name,
    d.employment_type_score     = s.employment_type_score,
    d.work_type_id              = s.work_type_id,
    d.work_type_name            = s.work_type_name,
    d.work_type_score           = s.work_type_score,
    d.job_category_id           = s.job_category_id,
    d.job_category_name         = s.job_category_name,
    d.job_category_score        = s.job_category_score,
    d.job_title_id              = s.job_title_id,
    d.job_title_name            = s.job_title_name,
    d.job_title_score           = s.job_title_score,
    d.job_level_id              = s.job_level_id,
    d.job_level_name            = s.job_level_name,
    d.job_level_score           = s.job_level_score,
    d.department_id             = s.department_id,
    d.department_type_name      = s.department_type_name,
    d.department_rating         = s.department_rating,
    d.company_key               = s.company_key,
    d.job_location_key          = s.job_location_key,
    d.deleted_flag              = 'N',
    d.last_update_date          = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (
 
              job_id,
              publish_date,
              hire_date,
              expiry_date,
              employment_period,
              salary_min,
              salary_max,
              currency_code,
              currency_name,
              demand_score,
              complexity_score,
              job_status,
              language_requirement,
              certifications_score,
              degree_requirement,
              academic_score,
              employment_type_id,
              employment_type_name,
              employment_type_score,
              work_type_id,
              work_type_name,
              work_type_score,
              job_category_id,
              job_category_name,
              job_category_score,
              job_title_id,
              job_title_name,
              job_title_score,
              job_level_id,
              job_level_name,
              job_level_score,
              department_id,
              department_type_name,
              department_rating,
              company_key,
              job_location_key,
              deleted_flag,
              creation_date,
              last_update_date
)
VALUES (
     
              s.job_id,
              s.publish_date,
              s.hire_date,
              s.expiry_date,
              s.employment_period,
              s.salary_min,
              s.salary_max,
              s.currency_code,
              s.currency_name,
              s.demand_score,
              s.complexity_score,
              s.job_status,
              s.language_requirement,
              s.certifications_score,
              s.degree_requirement,
              s.academic_score,
              s.employment_type_id,
              s.employment_type_name,
              s.employment_type_score,
              s.work_type_id,
              s.work_type_name,
              s.work_type_score,
              s.job_category_id,
              s.job_category_name,
              s.job_category_score,
              s.job_title_id,
              s.job_title_name,
              s.job_title_score,
              s.job_level_id,
              s.job_level_name,
              s.job_level_score,
              s.department_id,
              s.department_type_name,
              s.department_rating,
              s.company_key,
              s.job_location_key,
              'N',
              CURRENT_TIMESTAMP,
              CURRENT_TIMESTAMP
);
   
    
   UPDATE autonomous_dw_owner.dwh_job_dim d
SET d.deleted_flag = 'Y',
    d.last_update_date = CURRENT_TIMESTAMP
WHERE d.deleted_flag = 'N'
AND NOT EXISTS (
    SELECT 1
    FROM autonomous_dw_landing_owner.dwh_job c
    JOIN autonomous_dw_landing_owner.dwh_department dep
      ON c.department_id = dep.department_id
    WHERE c.job_id = d.job_id
);

    COMMIT;

---------------------------------------------------------------------- 
-- [5.] SUCCESS NOTIFICATION
----------------------------------------------------------------------

    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'DONE',
        end_timestamp = CURRENT_TIMESTAMP
    WHERE notification_id = v_notification_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;

        v_error := SQLERRM;

        UPDATE autonomous_dw_tech_owner.dwh_processes_notif
        SET status = 'ERROR',
            end_timestamp = CURRENT_TIMESTAMP,
            error_message = v_error
        WHERE notification_id = v_notification_id;

        COMMIT;

        RAISE_APPLICATION_ERROR(-20002, v_error);

END;
 ~';

EXECUTE IMMEDIATE v_sql;

--[1.] VERIFY IF THE PROCEDURE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_JOB_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_JOB_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_JOB_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_JOB_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_JOB_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_JOB_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_JOB_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_JOB_DIM'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_JOB_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

