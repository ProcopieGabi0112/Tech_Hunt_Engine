--AUTONOMOUS_DW_OWNER_DWH_COMPANY_DIM_JOB_1_v1.0.0
--"DWH_COMPANY_DIM JOB"
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
AND object_name ='PRC_ETL_COMPANY_INITIAL_LOAD';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_company_initial_load;';
END IF;
-- CREATE PROCEDURE FOR INITIAL LOAD
v_sql := q'[
             CREATE OR REPLACE PROCEDURE prc_etl_company_initial_load
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
        'ETL_COMPANY_INITIAL_LOAD_PROCESS',
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
                   FROM autonomous_dw_landing_owner.dwh_industry_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_organization_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_COMPANY_LOCATION_INITIAL_LOAD_PROCESS' 
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

    MERGE INTO autonomous_dw_owner.dwh_company_dim d
    USING (

       SELECT DISTINCT 
              c.company_id AS company_id,
              c.legal_entity_identifier AS company_identifier,
              c.name AS company_name,
              c.website AS company_website,
              c.foundation_date AS foundation_date,
              c.share_capital AS share_capital,
              c.net_profit AS net_profit,
              c.average_annual_revenue AS average_annual_revenue,
              c.total_assets AS total_assets,
              c.total_liabilities AS total_liabilities,
              c.debt_to_equity_ratio AS debt_to_equity_ratio,
              c.no_employees AS no_employees,
              c.rating AS company_rating,
              SUM(CASE WHEN d.no_open_positions > 0 THEN 1 ELSE 0 END) AS departments_with_open_positions,
              SUM(NVL(d.no_open_positions,0)) AS total_open_positions,
              AVG(d.rating) AS average_departments_rating,
              AVG(d.turnover_rate) AS average_turnover_rate,
              SUM(d.annual_budget) AS total_departments_budget,
              SUM(d.expenses) AS total_departments_expenses,
              ot.company_type_id AS company_type_id,
              ot.name AS company_type_name,
              it.industry_type_id AS industry_type_id,
              it.name AS industry_type_name,
              loc.company_location_key AS company_location_key
       FROM autonomous_dw_landing_owner.dwh_company c
            JOIN autonomous_dw_landing_owner.dwh_industry_type it ON c.industry_type_id = it.industry_type_id
            JOIN autonomous_dw_landing_owner.dwh_organization_type ot ON c.company_type_id = ot.company_type_id
            JOIN autonomous_dw_owner.dwh_company_location_dim loc ON c.company_location_id = loc.location_address_code
            LEFT JOIN autonomous_dw_landing_owner.dwh_department d ON c.company_id = d.company_id
       GROUP BY
               c.company_id, c.legal_entity_identifier, c.name, c.website,
               c.foundation_date, c.share_capital, c.net_profit,
               c.average_annual_revenue, c.total_assets, c.total_liabilities,
               c.debt_to_equity_ratio, c.no_employees, c.rating,
               ot.company_type_id, ot.name,
               it.industry_type_id, it.name,
               loc.company_location_key      
          ) s

    ON (d.company_id = s.company_id)

    WHEN MATCHED THEN UPDATE SET
          
              d.company_identifier                   = s.company_identifier,                 
              d.company_name                         = s.company_name,
              d.company_website                      = s.company_website,
              d.foundation_date                      = s.foundation_date,
              d.share_capital                        = s.share_capital,
              d.net_profit                           = s.net_profit,
              d.average_annual_revenue               = s.average_annual_revenue,
              d.total_assets                         = s.total_assets,
              d.total_liabilities                    = s.total_liabilities,
              d.debt_to_equity_ratio                 = s.debt_to_equity_ratio,
              d.no_employees                         = s.no_employees,
              d.company_rating                       = s.company_rating,
              d.departments_with_open_positions      = s.departments_with_open_positions,
              d.total_open_positions                 = s.total_open_positions,
              d.average_departments_rating           = s.average_departments_rating,
              d.average_turnover_rate                = s.average_turnover_rate,
              d.total_departments_budget             = s.total_departments_budget,
              d.total_departments_expenses           = s.total_departments_expenses,
              d.company_type_id                      = s.company_type_id,
              d.company_type_name                    = s.company_type_name,
              d.industry_type_id                     = s.industry_type_id,
              d.industry_type_name                   = s.industry_type_name,
              d.company_location_key                 = s.company_location_key,
              d.deleted_flag                         = 'N',
              d.last_update_date                     = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (
         
          company_id,
          company_identifier,
          company_name,
          company_website,
          foundation_date,
          share_capital,
          net_profit,
          average_annual_revenue,
          total_assets,
          total_liabilities,
          debt_to_equity_ratio,
          no_employees,
          company_rating,
          departments_with_open_positions,
          total_open_positions,
          average_departments_rating,
          average_turnover_rate,
          total_departments_budget,
          total_departments_expenses,
          company_type_id,
          company_type_name,
          industry_type_id,
          industry_type_name,
          company_location_key,
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
     
      s.company_id,
      s.company_identifier,
      s.company_name,
      s.company_website,
      s.foundation_date,
      s.share_capital,
      s.net_profit,
      s.average_annual_revenue,
      s.total_assets,
      s.total_liabilities,
      s.debt_to_equity_ratio,
      s.no_employees,
      s.company_rating,
      s.departments_with_open_positions,
      s.total_open_positions,
      s.average_departments_rating,
      s.average_turnover_rate,
      s.total_departments_budget,
      s.total_departments_expenses,
      s.company_type_id,
      s.company_type_name,
      s.industry_type_id,
      s.industry_type_name,
      s.company_location_key,
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
AND object_name ='PRC_ETL_COMPANY_INITIAL_LOAD';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_COMPANY_INITIAL_LOAD procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[3.] The PRC_ETL_COMPANY_INITIAL_LOAD procedure was created.');

EXECUTE IMMEDIATE 'BEGIN admin.prc_etl_company_initial_load; END;';

DBMS_OUTPUT.PUT_LINE('[4.] The PRC_ETL_COMPANY_INITIAL_LOAD is running.');

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_COMPANY_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_company_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
              CREATE OR REPLACE PROCEDURE prc_etl_company_daily
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
        'ETL_COMPANY_DAILY_PROCESS',
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
                   FROM autonomous_dw_landing_owner.dwh_industry_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_organization_type
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_tech_owner.dwh_processes_notif
                   WHERE process_name = 'ETL_COMPANY_LOCATION_DAILY_PROCESS' 
                   AND TO_DATE(process_date, 'YYYY-MM-DD') = TRUNC(SYSDATE)
                   AND process_type = 'DAILY'
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

    MERGE INTO autonomous_dw_owner.dwh_company_dim d
    USING (

       SELECT DISTINCT 
              c.company_id AS company_id,
              c.legal_entity_identifier AS company_identifier,
              c.name AS company_name,
              c.website AS company_website,
              c.foundation_date AS foundation_date,
              c.share_capital AS share_capital,
              c.net_profit AS net_profit,
              c.average_annual_revenue AS average_annual_revenue,
              c.total_assets AS total_assets,
              c.total_liabilities AS total_liabilities,
              c.debt_to_equity_ratio AS debt_to_equity_ratio,
              c.no_employees AS no_employees,
              c.rating AS company_rating,
              SUM(CASE WHEN d.no_open_positions > 0 THEN 1 ELSE 0 END) AS departments_with_open_positions,
              SUM(NVL(d.no_open_positions,0)) AS total_open_positions,
              AVG(d.rating) AS average_departments_rating,
              AVG(d.turnover_rate) AS average_turnover_rate,
              SUM(d.annual_budget) AS total_departments_budget,
              SUM(d.expenses) AS total_departments_expenses,
              ot.company_type_id AS company_type_id,
              ot.name AS company_type_name,
              it.industry_type_id AS industry_type_id,
              it.name AS industry_type_name,
              loc.company_location_key AS company_location_key
       FROM autonomous_dw_landing_owner.dwh_company c
            JOIN autonomous_dw_landing_owner.dwh_industry_type it ON c.industry_type_id = it.industry_type_id
            JOIN autonomous_dw_landing_owner.dwh_organization_type ot ON c.company_type_id = ot.company_type_id
            JOIN autonomous_dw_owner.dwh_company_location_dim loc ON c.company_location_id = loc.location_address_code
            LEFT JOIN autonomous_dw_landing_owner.dwh_department d ON c.company_id = d.company_id
       WHERE trunc(c.last_update_date) = trunc(sysdate - 1)
       GROUP BY
               c.company_id, c.legal_entity_identifier, c.name, c.website,
               c.foundation_date, c.share_capital, c.net_profit,
               c.average_annual_revenue, c.total_assets, c.total_liabilities,
               c.debt_to_equity_ratio, c.no_employees, c.rating,
               ot.company_type_id, ot.name,
               it.industry_type_id, it.name,
               loc.company_location_key      
          ) s

    ON (d.company_id = s.company_id)

    WHEN MATCHED THEN UPDATE SET
          
              d.company_identifier                   = s.company_identifier,                 
              d.company_name                         = s.company_name,
              d.company_website                      = s.company_website,
              d.foundation_date                      = s.foundation_date,
              d.share_capital                        = s.share_capital,
              d.net_profit                           = s.net_profit,
              d.average_annual_revenue               = s.average_annual_revenue,
              d.total_assets                         = s.total_assets,
              d.total_liabilities                    = s.total_liabilities,
              d.debt_to_equity_ratio                 = s.debt_to_equity_ratio,
              d.no_employees                         = s.no_employees,
              d.company_rating                       = s.company_rating,
              d.departments_with_open_positions      = s.departments_with_open_positions,
              d.total_open_positions                 = s.total_open_positions,
              d.average_departments_rating           = s.average_departments_rating,
              d.average_turnover_rate                = s.average_turnover_rate,
              d.total_departments_budget             = s.total_departments_budget,
              d.total_departments_expenses           = s.total_departments_expenses,
              d.company_type_id                      = s.company_type_id,
              d.company_type_name                    = s.company_type_name,
              d.industry_type_id                     = s.industry_type_id,
              d.industry_type_name                   = s.industry_type_name,
              d.company_location_key                 = s.company_location_key,
              d.deleted_flag                         = 'N',
              d.last_update_date                     = CURRENT_TIMESTAMP
                 
    WHEN NOT MATCHED THEN INSERT (
         
          company_id,
          company_identifier,
          company_name,
          company_website,
          foundation_date,
          share_capital,
          net_profit,
          average_annual_revenue,
          total_assets,
          total_liabilities,
          debt_to_equity_ratio,
          no_employees,
          company_rating,
          departments_with_open_positions,
          total_open_positions,
          average_departments_rating,
          average_turnover_rate,
          total_departments_budget,
          total_departments_expenses,
          company_type_id,
          company_type_name,
          industry_type_id,
          industry_type_name,
          company_location_key,
          deleted_flag,
          creation_date,
          last_update_date
)
VALUES (
     
      s.company_id,
      s.company_identifier,
      s.company_name,
      s.company_website,
      s.foundation_date,
      s.share_capital,
      s.net_profit,
      s.average_annual_revenue,
      s.total_assets,
      s.total_liabilities,
      s.debt_to_equity_ratio,
      s.no_employees,
      s.company_rating,
      s.departments_with_open_positions,
      s.total_open_positions,
      s.average_departments_rating,
      s.average_turnover_rate,
      s.total_departments_budget,
      s.total_departments_expenses,
      s.company_type_id,
      s.company_type_name,
      s.industry_type_id,
      s.industry_type_name,
      s.company_location_key,
      'N',
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP

);
    UPDATE autonomous_dw_owner.dwh_company_dim d
    SET
           d.deleted_flag = 'Y',
           d.last_update_date = CURRENT_TIMESTAMP
    WHERE NOT EXISTS (
                       SELECT 1
                       FROM autonomous_dw_landing_owner.dwh_company c
                            JOIN autonomous_dw_landing_owner.dwh_industry_type it ON c.industry_type_id = it.industry_type_id
                            JOIN autonomous_dw_landing_owner.dwh_organization_type ot ON c.company_type_id = ot.company_type_id
                            JOIN autonomous_dw_owner.dwh_company_location_dim loc ON c.company_location_id = loc.location_address_code
                            LEFT JOIN autonomous_dw_landing_owner.dwh_department d ON c.company_id = d.company_id
                       WHERE c.company_id = d.company_id
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
AND object_name ='PRC_ETL_COMPANY_DAILY';

IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,'The PRC_ETL_COMPANY_DAILY procedure wasnt created properly.');
END IF;
DBMS_OUTPUT.PUT_LINE('[5.] The PRC_ETL_COMPANY_DAILY procedure was created.');

SELECT COUNT(*) INTO v_count
FROM dba_scheduler_jobs
WHERE owner = 'ADMIN'
AND job_name = 'JOB_ETL_COMPANY_DAILY_PROCESS';

IF v_count > 0 THEN
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_COMPANY_DAILY_PROCESS',
        force    => TRUE
    );
END IF;

DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_COMPANY_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'ADMIN.PRC_ETL_COMPANY_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_COMPANY_DIM'

    );

    
DBMS_OUTPUT.PUT_LINE('[6.] The PRC_ETL_COMPANY_DAILY scheduled job was created.');

DBMS_OUTPUT.PUT_LINE('[7.] The script running is done!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

