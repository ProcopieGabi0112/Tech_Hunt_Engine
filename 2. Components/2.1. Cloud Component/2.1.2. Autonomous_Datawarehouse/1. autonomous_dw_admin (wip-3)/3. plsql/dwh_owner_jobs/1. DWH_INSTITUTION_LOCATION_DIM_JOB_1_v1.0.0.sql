--AUTONOMOUS_DW_OWNER_DWH_INSTITUTION_LOCATION_DIM_JOB_1_v1.0.0
--"DWH_INSTITUTION_LOCATION_DIM JOB"
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
-- Database_name: "G90CE4847B77DFA_TECHHUNTENGINEDB"	
-- Container_Name: "G90CE4847B77DFA_TECHHUNTENGINEDB"
-- Database_Type: "Pluggable Database (PDB)"

-- CREATE DAILY PROCEDURE IF EXIST
SELECT COUNT(*) INTO v_count
FROM dba_objects
WHERE owner = 'ADMIN'
AND object_type = 'PROCEDURE'
AND object_name ='PRC_ETL_INSTITUTION_LOCATION_DAILY';
IF v_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_etl_institution_location_daily;';
END IF;

-- CREATE PROCEDURE 
v_sql := q'[
             CREATE OR REPLACE PROCEDURE prc_etl_institution_location_daily
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
        'ETL_INSTITUTION_LOCATION_DAILY_PROCESS',
        TO_CHAR(SYSDATE,'YYYY-MM-DD'),
        'DAILY',
        CURRENT_TIMESTAMP,
        'IN_PROGRESS',
        USER
    )
     RETURNING notification_id INTO v_notification_id;
     COMMIT;
    ------------------------------------ 
    -- [2.] VALIDATE SOURCE TABLES SYNC
    ------------------------------------
 
    SELECT COUNT(*) INTO v_count
    FROM dual
    WHERE EXISTS ( SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_location 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_city 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_administrative_unit 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_administrative_unit_type 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                   SELECT 1 
                   FROM autonomous_dw_landing_owner.dwh_country 
                   WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                    SELECT 1 
                    FROM autonomous_dw_landing_owner.dwh_region 
                    WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                  ) AND EXISTS (
                    SELECT 1 
                    FROM autonomous_dw_landing_owner.dwh_language 
                    WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                   ) AND EXISTS (
                     SELECT 1 
                     FROM autonomous_dw_landing_owner.dwh_currency 
                     WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                    ) AND EXISTS ( 
                     SELECT 1 
                     FROM autonomous_dw_landing_owner.dwh_institution 
                     WHERE TRUNC(last_synced_at)=TRUNC(CURRENT_TIMESTAMP)
                    ) AND EXISTS (
                     SELECT 1 
                     FROM autonomous_dw_landing_owner.dwh_specialization 
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

    MERGE INTO autonomous_dw_owner.dwh_institution_location_dim d
    USING (
            SELECT DISTINCT
                  loc.location_id AS location_address_code,
                  loc.street_name || ' ' || loc.street_number AS location_address,
                  loc.postal_code,
                  TRIM(
                       NVL(loc.building,'') || ' ' ||
                       NVL(loc.staircase,'') || ' ' ||
                       NVL(loc.floor,'') || ' ' ||
                       NVL(loc.appartment_number,'')
                      ) AS location_details,
                 c.name AS city_name,
                 CASE WHEN c.is_capital='Y' THEN 'Y' ELSE 'N' END AS capital_city_flag,
                 c.latitude || ',' || c.longitude AS city_position,
                 c.population || ' people, ' || c.area || ' km2' AS city_stats,
                 aut.name || ' ' || au.name AS administrative_unit_name,
                 au.no_cities || ' cities, ' || au.population || ' people, ' || au.area || ' km2' AS administrative_unit_stats,
                 co.name AS country_name,
                 co.population || ' people, ' || co.area || ' km2' AS country_stats,
                 co.rating AS country_rating,
                 lang.name AS official_language_name,
                 cur.name AS currency_name,
                 reg.name AS region_name
            FROM autonomous_dw_landing_owner.dwh_user_spec us
            JOIN autonomous_dw_landing_owner.dwh_specialization sp ON us.specialization_id = sp.specialization_id
            JOIN autonomous_dw_landing_owner.dwh_institution inst  ON sp.institution_id = inst.institution_id
            JOIN autonomous_dw_landing_owner.dwh_location loc ON inst.location_id = loc.location_id
            JOIN autonomous_dw_landing_owner.dwh_city c ON loc.city_code = c.city_code
            JOIN autonomous_dw_landing_owner.dwh_administrative_unit au ON c.administrative_unit_id = au.administrative_unit_id
            JOIN autonomous_dw_landing_owner.dwh_administrative_unit_type aut ON au.administrative_unit_type_id = aut.administrative_unit_type_id
            JOIN autonomous_dw_landing_owner.dwh_country co ON au.country_id = co.country_id
            JOIN autonomous_dw_landing_owner.dwh_region reg ON co.region_id = reg.region_id
       LEFT JOIN autonomous_dw_landing_owner.dwh_language lang ON co.official_lang_code = lang.lang_code
       LEFT JOIN autonomous_dw_landing_owner.dwh_currency cur ON co.currency_code = cur.currency_code

          ) s
    ON (d.location_address_code = s.location_address_code)
    WHEN MATCHED THEN UPDATE SET
        d.location_address          = s.location_address,
        d.postal_code               = s.postal_code,
        d.location_details          = s.location_details,
        d.city_name                 = s.city_name,
        d.capital_city_flag         = s.capital_city_flag,
        d.city_position             = s.city_position,
        d.city_stats                = s.city_stats,
        d.administrative_unit_name  = s.administrative_unit_name,
        d.administrative_unit_stats = s.administrative_unit_stats,
        d.country_name              = s.country_name,
        d.country_stats             = s.country_stats,
        d.country_rating            = s.country_rating,
        d.official_language_name    = s.official_language_name,
        d.currency_name             = s.currency_name,
        d.region_name               = s.region_name
    
    WHEN NOT MATCHED THEN INSERT (
        location_address_code,
        location_address,
        postal_code,
        location_details,
        city_name,
        capital_city_flag,
        city_position,
        city_stats,
        administrative_unit_name,
        administrative_unit_stats,
        country_name,
        country_stats,
        country_rating,
        official_language_name,
        currency_name,
        region_name
    )
    VALUES 
    (
        s.location_address_code,
        s.location_address,
        s.postal_code,
        s.location_details,
        s.city_name,
        s.capital_city_flag,
        s.city_position,
        s.city_stats,
        s.administrative_unit_name,
        s.administrative_unit_stats,
        s.country_name,
        s.country_stats,
        s.country_rating,
        s.official_language_name,
        s.currency_name,
        s.region_name
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

BEGIN

    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'JOB_ETL_INSTITUTION_LOCATION_DAILY_PROCESS',
        force    => TRUE
    );

END;
/


--CREATE SCHEDULER JOB
BEGIN

    DBMS_SCHEDULER.CREATE_JOB (

        job_name        => 'JOB_ETL_INSTITUTION_LOCATION_DAILY_PROCESS',

        job_type        => 'STORED_PROCEDURE',

        job_action      => 'AUTONOMOUS_DW_OWNER.PRC_ETL_INSTITUTION_LOCATION_DAILY',

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',

        enabled         => TRUE,

        auto_drop       => FALSE,

        comments        => 'Daily ETL process for DWH_INSTITUTION_LOCATION_DIM'

    );

    DBMS_OUTPUT.PUT_LINE('[2.] The JOB_ETL_INSTITUTION_LOCATION_DAILY_PROCESS scheduler job was created.');

END;
/


--PROCEDURA IL 
CREATE OR REPLACE PROCEDURE prc_etl_institution_location_daily
AS
    v_count             NUMBER;
    v_notification_id   VARCHAR2(200);
    v_error             VARCHAR2(4000);

BEGIN

----------------------------------------------------------------------
-- [1.] START NOTIFICATION
----------------------------------------------------------------------
INSERT INTO autonomous_dw_tech_owner.dwh_processes_notif (
    process_name,
    process_date,
    process_type,
    start_timestamp,
    status,
    admin_user
)
VALUES (
    'ETL_INSTITUTION_LOCATION_DAILY_PROCESS',
    TO_CHAR(SYSDATE,'YYYY-MM-DD'),
    'DAILY',
    CURRENT_TIMESTAMP,
    'IN_PROGRESS',
    USER
)
RETURNING notification_id INTO v_notification_id;

COMMIT;

----------------------------------------------------------------------
-- [2.] CHECK NOMENCLATURE DATA SYNC
----------------------------------------------------------------------

SELECT COUNT(*)
INTO v_count
FROM dual
WHERE EXISTS (
    SELECT 1 FROM autonomous_dw_landing_owner.dwh_location
    WHERE TRUNC(last_synced_at) = TRUNC(SYSDATE)
)
AND EXISTS (
    SELECT 1 FROM autonomous_dw_landing_owner.dwh_city
    WHERE TRUNC(last_synced_at) = TRUNC(SYSDATE)
)
AND EXISTS (
    SELECT 1 FROM autonomous_dw_landing_owner.dwh_administrative_unit
    WHERE TRUNC(last_synced_at) = TRUNC(SYSDATE)
)
AND EXISTS (
    SELECT 1 FROM autonomous_dw_landing_owner.dwh_country
    WHERE TRUNC(last_synced_at) = TRUNC(SYSDATE)
)
AND EXISTS (
    SELECT 1 FROM autonomous_dw_landing_owner.dwh_region
    WHERE TRUNC(last_synced_at) = TRUNC(SYSDATE)
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

----------------------------------------------------------------------
-- [3.] MERGE INTO DIM TABLE
----------------------------------------------------------------------

MERGE INTO autonomous_dw_owner.dwh_institution_location_dim d
USING (
    SELECT DISTINCT
        loc.location_id AS location_address_code,
        loc.street_name || ' ' || loc.street_number AS location_address,
        loc.postal_code,
        TRIM(
            NVL(loc.building,'') || ' ' ||
            NVL(loc.staircase,'') || ' ' ||
            NVL(loc.floor,'') || ' ' ||
            NVL(loc.appartment_number,'')
        ) AS location_details,
        c.name AS city_name,
        CASE WHEN c.is_capital = 'Y' THEN 'Y' ELSE 'N' END AS capital_city_flag,
        c.latitude || ',' || c.longitude AS city_position,
        c.population || ' people, ' || c.area || ' km2' AS city_stats,
        aut.name || ' ' || au.name AS administrative_unit_name,
        au.no_cities || ' cities, ' || au.population || ' people, ' || au.area || ' km2' AS administrative_unit_stats,
        co.name AS country_name,
        co.population || ' people, ' || co.area || ' km2' AS country_stats,
        co.rating AS country_rating,
        lang.name AS official_language_name,
        cur.name AS currency_name,
        reg.name AS region_name
    FROM autonomous_dw_landing_owner.dwh_user_spec us
    JOIN autonomous_dw_landing_owner.dwh_specialization sp
        ON us.specialization_id = sp.specialization_id
    JOIN autonomous_dw_landing_owner.dwh_institution inst
        ON sp.institution_id = inst.institution_id
    JOIN autonomous_dw_landing_owner.dwh_location loc
        ON inst.location_id = loc.location_id
    JOIN autonomous_dw_landing_owner.dwh_city c
        ON loc.city_code = c.city_code
    JOIN autonomous_dw_landing_owner.dwh_administrative_unit au
        ON c.administrative_unit_id = au.administrative_unit_id
    JOIN autonomous_dw_landing_owner.dwh_administrative_unit_type aut
        ON au.administrative_unit_type_id = aut.administrative_unit_type_id
    JOIN autonomous_dw_landing_owner.dwh_country co
        ON au.country_id = co.country_id
    JOIN autonomous_dw_landing_owner.dwh_region reg
        ON co.region_id = reg.region_id
    LEFT JOIN autonomous_dw_landing_owner.dwh_language lang
        ON co.official_lang_code = lang.lang_code
    LEFT JOIN autonomous_dw_landing_owner.dwh_currency cur
        ON co.currency_code = cur.currency_code
) s
ON (d.location_address_code = s.location_address_code)

WHEN MATCHED THEN UPDATE SET
    d.location_address          = s.location_address,
    d.postal_code               = s.postal_code,
    d.location_details          = s.location_details,
    d.city_name                 = s.city_name,
    d.capital_city_flag         = s.capital_city_flag,
    d.city_position             = s.city_position,
    d.city_stats                = s.city_stats,
    d.administrative_unit_name  = s.administrative_unit_name,
    d.administrative_unit_stats = s.administrative_unit_stats,
    d.country_name              = s.country_name,
    d.country_stats             = s.country_stats,
    d.country_rating            = s.country_rating,
    d.official_language_name    = s.official_language_name,
    d.currency_name             = s.currency_name,
    d.region_name               = s.region_name

WHEN NOT MATCHED THEN INSERT (
    location_address_code,
    location_address,
    postal_code,
    location_details,
    city_name,
    capital_city_flag,
    city_position,
    city_stats,
    administrative_unit_name,
    administrative_unit_stats,
    country_name,
    country_stats,
    country_rating,
    official_language_name,
    currency_name,
    region_name
)
VALUES (
    s.location_address_code,
    s.location_address,
    s.postal_code,
    s.location_details,
    s.city_name,
    s.capital_city_flag,
    s.city_position,
    s.city_stats,
    s.administrative_unit_name,
    s.administrative_unit_stats,
    s.country_name,
    s.country_stats,
    s.country_rating,
    s.official_language_name,
    s.currency_name,
    s.region_name
);

COMMIT;

----------------------------------------------------------------------
-- [4.] SUCCESS NOTIFICATION
----------------------------------------------------------------------

UPDATE autonomous_dw_tech_owner.dwh_processes_notif
SET status = 'DONE',
    end_timestamp = CURRENT_TIMESTAMP
WHERE notification_id = v_notification_id;

COMMIT;

EXCEPTION
WHEN OTHERS THEN

    v_error := SQLERRM;

    UPDATE autonomous_dw_tech_owner.dwh_processes_notif
    SET status = 'ERROR',
        end_timestamp = CURRENT_TIMESTAMP,
        error_message = v_error
    WHERE notification_id = v_notification_id;

    COMMIT;

    RAISE;
END;
/