--AUTONOMOUS_DW_OWNER_DWH_CERTIFICATION_DIM_JOB_1_v1.0.0
--"DWH_CERTIFICATION_DIM JOB"
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
AND object_name ='PRC_ETL_CERTIFICATION_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_certification_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
             CREATE OR REPLACE PROCEDURE prc_etl_certification_initial_load
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
        'ETL_CERTIFICATION_INITIAL_LOAD_PROCESS',
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
                   FROM autonomous_dw_landing_owner.dwh_lang_level 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_language
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
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

    MERGE INTO autonomous_dw_owner.dwh_certification_dim d
    USING (
       SELECT DISTINCT 
          ll.lang_level_id AS lang_level_id,
          ll.lang_code AS lang_code,
          ll.name AS certification_name,
          ll.nivel AS certification_level,
          ll.validity_period AS certification_validity,
          ll.rating AS certification_rating,
          l.name AS language_name,
          l.no_speakers AS no_speakers,
          l.no_countries AS no_countries,
          l.no_companies AS no_companies,
          l.rating AS language_rating
        FROM autonomous_dw_landing_owner.dwh_user_level ul
        JOIN autonomous_dw_landing_owner.dwh_lang_level ll
             ON ul.lang_level_id = ll.lang_level_id
        JOIN autonomous_dw_landing_owner.dwh_language l
             ON ll.lang_code = l.lang_code
       
               ) s
    ON (d.lang_level_id = s.lang_level_id)

    WHEN MATCHED THEN UPDATE SET

          d.lang_code                      = s.lang_code,
          d.certification_name             = s.certification_name,
          d.certification_level            = s.certification_level,
          d.certification_validity         = s.certification_validity,
          d.certification_rating           = s.certification_rating,
          d.language_name                  = s.language_name,
          d.no_speakers                    = s.no_speakers,
          d.no_countries                   = s.no_countries,
          d.no_companies                   = s.no_companies,
          d.language_rating                = s.language_rating,
          d.deleted_flag                   = 'N',
          d.last_update_date               = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

          lang_level_id,
          lang_code,
          certification_name,
          certification_level,
          certification_validity,
          certification_rating,
          language_name,
          no_speakers,
          no_countries,
          no_companies,
          language_rating,
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
      s.lang_level_id,
      s.lang_code,
      s.certification_name,
      s.certification_level,
      s.certification_validity,
      s.certification_rating,
      s.language_name,
      s.no_speakers,
      s.no_countries,
      s.no_companies,
      s.language_rating,
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
 ]';

 EXECUTE IMMEDIATE v_sql;

--[1.] VERIFY IF THE PROCEDURE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_CERTIFICATION_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_CERTIFICATION_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_CERTIFICATION_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_certification_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_CERTIFICATION_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_CERTIFICATION_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_certification_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
              CREATE OR REPLACE PROCEDURE prc_etl_certification_daily
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
        'ETL_CERTIFICATION_DAILY_PROCESS',
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
                   FROM autonomous_dw_landing_owner.dwh_lang_level 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_language
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
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

    MERGE INTO autonomous_dw_owner.dwh_certification_dim d
    USING (
       SELECT DISTINCT 
          ll.lang_level_id AS lang_level_id,
          ll.lang_code AS lang_code,
          ll.name AS certification_name,
          ll.nivel AS certification_level,
          ll.validity_period AS certification_validity,
          ll.rating AS certification_rating,
          l.name AS language_name,
          l.no_speakers AS no_speakers,
          l.no_countries AS no_countries,
          l.no_companies AS no_companies,
          l.rating AS language_rating
        FROM autonomous_dw_landing_owner.dwh_user_level ul
        JOIN autonomous_dw_landing_owner.dwh_lang_level ll
             ON ul.lang_level_id = ll.lang_level_id
        JOIN autonomous_dw_landing_owner.dwh_language l
             ON ll.lang_code = l.lang_code
        WHERE trunc(ul.last_update_date) = trunc(sysdate-1)
       
               ) s
    ON (d.lang_level_id = s.lang_level_id)

    WHEN MATCHED THEN UPDATE SET

          d.lang_code                      = s.lang_code,
          d.certification_name             = s.certification_name,
          d.certification_level            = s.certification_level,
          d.certification_validity         = s.certification_validity,
          d.certification_rating           = s.certification_rating,
          d.language_name                  = s.language_name,
          d.no_speakers                    = s.no_speakers,
          d.no_countries                   = s.no_countries,
          d.no_companies                   = s.no_companies,
          d.language_rating                = s.language_rating,
          d.deleted_flag                   = 'N',
          d.last_update_date               = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (

          lang_level_id,
          lang_code,
          certification_name,
          certification_level,
          certification_validity,
          certification_rating,
          language_name,
          no_speakers,
          no_countries,
          no_companies,
          language_rating,
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
      s.lang_level_id,
      s.lang_code,
      s.certification_name,
      s.certification_level,
      s.certification_validity,
      s.certification_rating,
      s.language_name,
      s.no_speakers,
      s.no_countries,
      s.no_companies,
      s.language_rating,
      'N',
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
);

    
    
    UPDATE autonomous_dw_owner.dwh_certification_dim d
    SET
           d.deleted_flag = 'Y',
           d.last_update_date = CURRENT_TIMESTAMP
    WHERE NOT EXISTS (
                       SELECT 1
                       FROM autonomous_dw_landing_owner.dwh_user_level ul
                       JOIN autonomous_dw_landing_owner.dwh_lang_level ll ON ul.lang_level_id = ll.lang_level_id
                       WHERE ll.lang_level_id = d.lang_level_id
                     )
    AND d.deleted_flag = 'N';

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
 ]';

EXECUTE IMMEDIATE v_sql;

--[1.] VERIFY IF THE PROCEDURE WAS CREATED RIGHT
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_CERTIFICATION_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_CERTIFICATION_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_CERTIFICATION_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_CERTIFICATION_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_CERTIFICATION_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_CERTIFICATION_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_CERTIFICATION_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_CERTIFICATION_DIM'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_CERTIFICATION_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

