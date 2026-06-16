\echo '=== START INIT SCRIPT 02_pg_db_tech_owner.sql ==='

-- 1. Create schema if not exists
CREATE SCHEMA IF NOT EXISTS db_tech_owner AUTHORIZATION db_tech_owner;

\echo '==================================';
\echo ' 1. CREATE PROCESSES_NOTIF TABLE  ';
\echo '==================================';

-- 2. Drop table if exists
DROP TABLE IF EXISTS db_tech_owner.processes_notif CASCADE;
-- 3. Create table
CREATE TABLE db_tech_owner.processes_notif (
    notification_id      VARCHAR(200) PRIMARY KEY,
    process_name         VARCHAR(100) NOT NULL,
    process_date         VARCHAR(10) NOT NULL,
    process_type         VARCHAR(30) NOT NULL,
    start_timestamp      TIMESTAMP NOT NULL,
    end_timestamp        TIMESTAMP,
    status               VARCHAR(30) NOT NULL CHECK (status IN ('IN_PROGRESS','ERROR','DONE')),
    error_message        VARCHAR(250),
    admin_user           VARCHAR(50) NOT NULL,

    creation_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by           VARCHAR(50) NOT NULL,
    source_system        VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env'))
);
-- 4. Comments
COMMENT ON TABLE db_tech_owner.processes_notif IS
'The table contains the informations about the notifications that will be displayed when a process will start.';

COMMENT ON COLUMN db_tech_owner.processes_notif.notification_id IS 'The id of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.process_name IS 'The name of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.process_date IS 'The date when the process was started.';
COMMENT ON COLUMN db_tech_owner.processes_notif.process_type IS 'The type of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.start_timestamp IS 'The start time of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.end_timestamp IS 'The end time of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.status IS 'The status of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.error_message IS 'The error message of the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.admin_user IS 'The user who started the process.';
COMMENT ON COLUMN db_tech_owner.processes_notif.creation_date IS 'Technical Column - The creation date of the record.';
COMMENT ON COLUMN db_tech_owner.processes_notif.created_by IS 'Technical Column - The user who created the record.';
COMMENT ON COLUMN db_tech_owner.processes_notif.source_system IS 'Technical Column - The source system of the record.';

-- 5. Drop sequence if exists
DROP SEQUENCE IF EXISTS db_tech_owner.seq_processes_notif_pk;

-- 6. Create sequence
CREATE SEQUENCE db_tech_owner.seq_processes_notif_pk
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

-- 7. Drop trigger if exists
DROP TRIGGER IF EXISTS trg_processes_notif_pk ON db_tech_owner.processes_notif;

-- 8. Create trigger for PK
CREATE OR REPLACE FUNCTION db_tech_owner.fn_processes_notif_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.notification_id IS NULL THEN
        NEW.notification_id := nextval('db_tech_owner.seq_processes_notif_pk');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_processes_notif_pk
BEFORE INSERT ON db_tech_owner.processes_notif
FOR EACH ROW EXECUTE FUNCTION db_tech_owner.fn_processes_notif_pk();

-- 9. Drop trigger for technical columns if exists
DROP TRIGGER IF EXISTS trg_processes_notif_tech_col ON db_tech_owner.processes_notif;

-- 10. Create trigger for technical columns
CREATE OR REPLACE FUNCTION db_tech_owner.fn_processes_notif_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by := CURRENT_USER;
    NEW.creation_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_processes_notif_tech_col
BEFORE INSERT ON db_tech_owner.processes_notif
FOR EACH ROW EXECUTE FUNCTION db_tech_owner.fn_processes_notif_tech_col();

\echo '==============================================================';
\echo ' 2. CREARE FUNCTIE STERGERE NOTIFICARI PROCESSES_NOTIF TABLE  ';
\echo '==============================================================';

CREATE OR REPLACE FUNCTION db_tech_owner.fn_cleanup_processes_notif()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_ts TIMESTAMP := NOW();
    v_end_ts   TIMESTAMP;
    v_deleted  INTEGER := 0;
    v_exists   INTEGER := 0;
    v_error    TEXT;
BEGIN
    -- 1. Verificăm dacă există rânduri de șters (mai vechi de 1 lună)
    SELECT COUNT(*) INTO v_exists
    FROM db_tech_owner.processes_notif
    WHERE creation_date < NOW() - INTERVAL '1 month';

    -- Dacă nu există → ieșim fără notificări
    IF v_exists = 0 THEN
        RETURN;
    END IF;

    -- 2. IN_PROGRESS
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, status, admin_user
    ) VALUES (
        'PROCESSES_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        'IN_PROGRESS',
        'POSTGRES_SYSTEM'
    );

    -- 3. Cleanup logic
    DELETE FROM db_tech_owner.processes_notif
    WHERE creation_date < NOW() - INTERVAL '1 month';

    v_deleted := SQL%ROWCOUNT;
    v_end_ts := NOW();

    -- 4. DONE
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'PROCESSES_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        v_end_ts,
        'DONE',
        'Deleted ' || v_deleted || ' rows older than 1 month',
        'POSTGRES_SYSTEM'
    );

EXCEPTION WHEN OTHERS THEN
    v_end_ts := NOW();
    v_error := SQLERRM;

    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'PROCESSES_NOTIF_CLEAN_UP_PROCESS',
         TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        v_end_ts,
        'ERROR',
        v_error,
        'POSTGRES_SYSTEM'
    );
END;
$$;



\echo '=================================';
\echo ' 3. CREATE CONNECT_NOTIF TABLE   ';
\echo '=================================';

-- 2. Drop table if exists
DROP TABLE IF EXISTS db_tech_owner.connect_notif CASCADE;

-- 3. Create table
CREATE TABLE db_tech_owner.connect_notif (
    conn_key              VARCHAR(200) PRIMARY KEY,
    user_name             VARCHAR(100),
    start_conn_timestamp  TIMESTAMP,
    end_conn_timestamp    TIMESTAMP,
    schema                VARCHAR(50),
    user_ip               VARCHAR(50),
    action                VARCHAR(10),

    creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by            VARCHAR(50) NOT NULL,
    source_system         VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env'))
);

-- 4. Comments
COMMENT ON TABLE db_tech_owner.connect_notif IS
'The table contains information about the users that connect to the database.';

COMMENT ON COLUMN db_tech_owner.connect_notif.conn_key IS 'The audit id of the connection.';
COMMENT ON COLUMN db_tech_owner.connect_notif.user_name IS 'The user name of the connection.';
COMMENT ON COLUMN db_tech_owner.connect_notif.start_conn_timestamp IS 'The start timestamp of the connection.';
COMMENT ON COLUMN db_tech_owner.connect_notif.end_conn_timestamp IS 'The end timestamp of the connection.';
COMMENT ON COLUMN db_tech_owner.connect_notif.schema IS 'The schema where the user entered.';
COMMENT ON COLUMN db_tech_owner.connect_notif.user_ip IS 'The IP of the user.';
COMMENT ON COLUMN db_tech_owner.connect_notif.action IS 'The action of the user.';
COMMENT ON COLUMN db_tech_owner.connect_notif.creation_date IS 'Technical Column - The creation date of the record.';
COMMENT ON COLUMN db_tech_owner.connect_notif.created_by IS 'Technical Column - The user who created the record.';
COMMENT ON COLUMN db_tech_owner.connect_notif.source_system IS 'Technical Column - The source system of the record.';

-- 5. Drop trigger for technical columns if exists
DROP TRIGGER IF EXISTS trg_connect_notif_tech_col ON db_tech_owner.connect_notif;

-- 6. Create trigger function for technical columns
CREATE OR REPLACE FUNCTION db_tech_owner.fn_connect_notif_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by := CURRENT_USER;
    NEW.creation_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create trigger
CREATE TRIGGER trg_connect_notif_tech_col
BEFORE INSERT ON db_tech_owner.connect_notif
FOR EACH ROW EXECUTE FUNCTION db_tech_owner.fn_connect_notif_tech_col();

\echo '=================================================';
\echo ' 4. CREARE FUNCTIE POPULARE CONNECT_NOTIF TABLE  ';
\echo '=================================================';

CREATE OR REPLACE FUNCTION db_tech_owner.fn_population_connect_notif()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_key TEXT;
BEGIN
    FOR r IN
        SELECT
            pid,
            usename,
            client_addr,
            application_name,
            state,
            backend_start,
            state_change
        FROM pg_stat_activity
        WHERE usename IS NOT NULL
          AND usename NOT IN ('postgres')
          AND client_addr IS NOT NULL
    LOOP
        v_key := r.pid || '_' || r.usename;

        -- Dacă nu există → LOGIN
        IF NOT EXISTS (
            SELECT 1 FROM db_tech_owner.connect_notif
            WHERE conn_key = v_key
        ) THEN
            INSERT INTO db_tech_owner.connect_notif (
                conn_key,
                user_name,
                start_conn_timestamp,
                end_conn_timestamp,
                schema,
                user_ip,
                action,
                created_by,
                source_system
            ) VALUES (
                v_key,
                r.usename,
                r.backend_start,
                NULL,
                r.usename,
                r.client_addr::text,
                'LOGIN',
                'POSTGRES_SYSTEM',
                'db_env'
            );

        -- Dacă există și sesiunea e inactivă → LOGOUT
        ELSIF r.state = 'idle' THEN
            UPDATE db_tech_owner.connect_notif
            SET end_conn_timestamp = r.state_change,
                action = 'LOGOUT'
            WHERE conn_key = v_key
              AND end_conn_timestamp IS NULL;
        END IF;
    END LOOP;
END;
$$;

\echo '=======================================================';
\echo ' 5. PROGRAMARE JOB POPULARE TABELA CONNECT_NOTIF TABLE ';
\echo '=======================================================';

SELECT cron.schedule(
    'job_population_connect_notif',
    '*/5 * * * *',
    $$SELECT db_tech_owner.fn_population_connect_notif();$$
);

CREATE OR REPLACE FUNCTION db_tech_owner.fn_cleanup_connect_notif()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_ts TIMESTAMP := NOW();
    v_end_ts   TIMESTAMP;
    v_deleted  INTEGER := 0;
    v_exists   INTEGER := 0;
    v_error    TEXT;
BEGIN
    -- 1. Verificăm dacă există rânduri de șters (mai vechi de 7 zile)
    SELECT COUNT(*) INTO v_exists
    FROM db_tech_owner.connect_notif
    WHERE creation_date < NOW() - INTERVAL '7 days';

    -- Dacă nu există → ieșim fără notificări
    IF v_exists = 0 THEN
        RETURN;
    END IF;

    -- 2. IN_PROGRESS
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, status, admin_user
    ) VALUES (
        'CONNECT_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        'IN_PROGRESS',
        'POSTGRES_SYSTEM'
    );

    -- 3. Cleanup logic
    DELETE FROM db_tech_owner.connect_notif
    WHERE creation_date < NOW() - INTERVAL '7 days';

    v_deleted := SQL%ROWCOUNT;
    v_end_ts := NOW();

    -- 4. DONE
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'CONNECT_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        v_end_ts,
        'DONE',
        'Deleted ' || v_deleted || ' rows older than 1 week',
        'POSTGRES_SYSTEM'
    );

EXCEPTION WHEN OTHERS THEN
    v_end_ts := NOW();
    v_error := SQLERRM;

    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'CONNECT_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        v_end_ts,
        'ERROR',
        v_error,
        'POSTGRES_SYSTEM'
    );
END;
$$;

\echo '================================================';
\echo ' 6. PROGRAMARE JOB STERGERE CONNECT_NOTIF TABLE ';
\echo '================================================';

SELECT cron.schedule(
    'job_cleanup_connect_notif',
    '0 3 * * *',
    $$SELECT db_tech_owner.fn_cleanup_connect_notif();$$
);

\echo '==================================';
\echo ' 7. CREATE COMMANDS_NOTIF TABLE   ';
\echo '==================================';

-- 2. Drop table if exists
DROP TABLE IF EXISTS db_tech_owner.commands_notif CASCADE;

-- 3. Create table
CREATE TABLE db_tech_owner.commands_notif (
    comm_key              VARCHAR(200) PRIMARY KEY,
    user_name             VARCHAR(100) NOT NULL,
    command_timestamp     TIMESTAMP NOT NULL,
    sql_command           VARCHAR(4000) NOT NULL,
    command_type          VARCHAR(30) NOT NULL,
    schema                VARCHAR(50) NOT NULL,

    creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by            VARCHAR(50) NOT NULL,
    source_system         VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env'))
);

-- 4. Comments
COMMENT ON TABLE db_tech_owner.commands_notif IS
'The table contains information about all the commands that were executed by users connected to the database.';

COMMENT ON COLUMN db_tech_owner.commands_notif.comm_key IS 'The audit id of the command.';
COMMENT ON COLUMN db_tech_owner.commands_notif.user_name IS 'The user name of the command.';
COMMENT ON COLUMN db_tech_owner.commands_notif.command_timestamp IS 'The timestamp of the command.';
COMMENT ON COLUMN db_tech_owner.commands_notif.sql_command IS 'The description of the command.';
COMMENT ON COLUMN db_tech_owner.commands_notif.command_type IS 'The type of the command.';
COMMENT ON COLUMN db_tech_owner.commands_notif.schema IS 'The schema where the command was executed.';
COMMENT ON COLUMN db_tech_owner.commands_notif.creation_date IS 'Technical Column - The creation date of the record.';
COMMENT ON COLUMN db_tech_owner.commands_notif.created_by IS 'Technical Column - The user who created the record.';
COMMENT ON COLUMN db_tech_owner.commands_notif.source_system IS 'Technical Column - The source system of the record.';

-- 5. Drop trigger for technical columns if exists
DROP TRIGGER IF EXISTS trg_commands_notif_tech_col ON db_tech_owner.commands_notif;

-- 6. Create trigger function for technical columns
CREATE OR REPLACE FUNCTION db_tech_owner.fn_commands_notif_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by := CURRENT_USER;
    NEW.creation_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create trigger
CREATE TRIGGER trg_commands_notif_tech_col
BEFORE INSERT ON db_tech_owner.commands_notif
FOR EACH ROW EXECUTE FUNCTION db_tech_owner.fn_commands_notif_tech_col();

\echo '=============================================================';
\echo ' 8. CREARE FUNCTIE STERGERE NOTIFICARI COMMANDS_NOTIF TABLE  ';
\echo '=============================================================';

CREATE OR REPLACE FUNCTION db_tech_owner.fn_cleanup_commands_notif()
RETURNS void AS $$
DECLARE
    v_start_ts   TIMESTAMP := NOW();
    v_end_ts     TIMESTAMP;
    v_deleted    INTEGER := 0;
BEGIN
    -- 1. Verificăm dacă există rânduri de șters
    PERFORM 1 FROM db_tech_owner.commands_notif
    WHERE creation_date < NOW() - INTERVAL '7 days';

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- 2. Notification IN_PROGRESS
    INSERT INTO db_tech_owner.processes_notif
    (process_name, process_date, process_type, start_timestamp, status, admin_user)
    VALUES
    ('COMMANDS_NOTIF_CLEAN_UP_PROCESS',
     TO_CHAR(NOW(), 'YYYY-MM-DD'),
     'CLEAN_UP',
     v_start_ts,
     'IN_PROGRESS',
     CURRENT_USER);

    -- 3. Cleanup logic
    DELETE FROM db_tech_owner.commands_notif
    WHERE creation_date < NOW() - INTERVAL '7 days';

    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    v_end_ts := NOW();

    -- 4. Notification DONE
    INSERT INTO db_tech_owner.processes_notif
    (process_name, process_date, process_type, start_timestamp, end_timestamp, status, error_message, admin_user)
    VALUES
    ('COMMANDS_NOTIF_CLEAN_UP_PROCESS',
     TO_CHAR(NOW(), 'YYYY-MM-DD'),
     'CLEAN_UP',
     v_start_ts,
     v_end_ts,
     'DONE',
     'Deleted ' || v_deleted || ' rows older than 1 week',
     CURRENT_USER);

EXCEPTION WHEN OTHERS THEN
    v_end_ts := NOW();

    INSERT INTO db_tech_owner.processes_notif
    (process_name, process_date, process_type, start_timestamp, end_timestamp, status, error_message, admin_user)
    VALUES
    ('COMMANDS_NOTIF_CLEAN_UP_PROCESS',
     TO_CHAR(NOW(), 'YYYY-MM-DD'),
     'CLEAN_UP',
     v_start_ts,
     v_end_ts,
     'ERROR',
     SQLERRM,
     CURRENT_USER);

    RAISE;
END;
$$ LANGUAGE plpgsql;

\echo '==================================================';
\echo ' 9. PROGRAMARE JOB CLEAN UP COMMANDS_NOTIF TABLE  ';
\echo '==================================================';

SELECT cron.schedule(
    'job_cleanup_commands_notif',
    '0 3 * * *',  -- daily at 03:00
    $$SELECT db_tech_owner.fn_cleanup_commands_notif();$$
);

\echo '=====----==========================';
\echo ' 10. CREATE RESOURCES_NOTIF TABLE  ';
\echo '=========----======================';

-- 2. Drop table if exists
DROP TABLE IF EXISTS db_tech_owner.resources_notif CASCADE;

-- 3. Create table
CREATE TABLE db_tech_owner.resources_notif (
    snapshot_id          BIGINT PRIMARY KEY,
    snapshot_timestamp   TIMESTAMP NOT NULL,
    tablespace_name      VARCHAR(100) NOT NULL,
    total_space_mb       BIGINT NOT NULL,
    used_space_mb        BIGINT NOT NULL,
    free_space_mb        BIGINT NOT NULL,
    usage_percentage     NUMERIC(5,2) NOT NULL,

    creation_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by           VARCHAR(50) NOT NULL,
    source_system        VARCHAR(20) DEFAULT 'pg_env' NOT NULL CHECK (source_system IN ('db_env','dw_env','pg_env'))
);

-- 4. Comments
COMMENT ON TABLE db_tech_owner.resources_notif IS
'The table contains the recent information about resources from database.';

COMMENT ON COLUMN db_tech_owner.resources_notif.snapshot_id IS 'The id of the snapshot when the resources were verified.';
COMMENT ON COLUMN db_tech_owner.resources_notif.snapshot_timestamp IS 'The timestamp of the snapshot when the resources were verified.';
COMMENT ON COLUMN db_tech_owner.resources_notif.tablespace_name IS 'The tablespace name where the resources were verified.';
COMMENT ON COLUMN db_tech_owner.resources_notif.total_space_mb IS 'The total space in megabytes when the snapshot was made.';
COMMENT ON COLUMN db_tech_owner.resources_notif.used_space_mb IS 'The used space in megabytes when the snapshot was made.';
COMMENT ON COLUMN db_tech_owner.resources_notif.free_space_mb IS 'The free space in megabytes when the snapshot was made.';
COMMENT ON COLUMN db_tech_owner.resources_notif.usage_percentage IS 'The usage percentage of the resources when the snapshot was made.';
COMMENT ON COLUMN db_tech_owner.resources_notif.creation_date IS 'Technical Column - The creation date of the record.';
COMMENT ON COLUMN db_tech_owner.resources_notif.created_by IS 'Technical Column - The user who created the record.';
COMMENT ON COLUMN db_tech_owner.resources_notif.source_system IS 'Technical Column - The source system of the record.';

-- 5. Drop sequence if exists
DROP SEQUENCE IF EXISTS db_tech_owner.seq_resources_notif_pk;

-- 6. Create sequence
CREATE SEQUENCE db_tech_owner.seq_resources_notif_pk
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;

-- 7. Drop PK trigger if exists
DROP TRIGGER IF EXISTS trg_resources_notif_pk ON db_tech_owner.resources_notif;

-- 8. Create PK trigger function
CREATE OR REPLACE FUNCTION db_tech_owner.fn_resources_notif_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.snapshot_id IS NULL THEN
        NEW.snapshot_id := NEXTVAL('db_tech_owner.seq_resources_notif_pk');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. Create PK trigger
CREATE TRIGGER trg_resources_notif_pk
BEFORE INSERT ON db_tech_owner.resources_notif
FOR EACH ROW EXECUTE FUNCTION db_tech_owner.fn_resources_notif_pk();

-- 10. Drop technical trigger if exists
DROP TRIGGER IF EXISTS trg_resources_notif_tech_col ON db_tech_owner.resources_notif;

-- 11. Create technical trigger function
CREATE OR REPLACE FUNCTION db_tech_owner.fn_resources_notif_tech_col()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by := CURRENT_USER;
    NEW.creation_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 12. Create technical trigger
CREATE TRIGGER trg_resources_notif_tech_col
BEFORE INSERT ON db_tech_owner.resources_notif
FOR EACH ROW EXECUTE FUNCTION db_tech_owner.fn_resources_notif_tech_col();

\echo '=======================================';
\echo ' 11. CREATE VIEW RESOURCES_NOTIF TABLE ';
\echo '=======================================';

CREATE OR REPLACE VIEW db_tech_owner.vw_tablespace_usage AS
SELECT
    'pg_default' AS tablespace,
    pg_tablespace_size('pg_default') / 1024 / 1024 AS total_mb,
    pg_database_size(current_database()) / 1024 / 1024 AS used_mb,
    (pg_tablespace_size('pg_default') - pg_database_size(current_database())) / 1024 / 1024 AS free_mb;

\echo '===================================================';
\echo ' 12. CREATE FUNCTIE POPULARE RESOURCES_NOTIF TABLE ';
\echo '===================================================';

CREATE OR REPLACE FUNCTION db_tech_owner.fn_population_resources_notif()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_ts TIMESTAMP := NOW();
    v_end_ts   TIMESTAMP;
    v_error    TEXT;
BEGIN
    -- 1. IN_PROGRESS
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, status, admin_user
    ) VALUES (
        'RESOURCES_NOTIF_POPULATION_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'POPULATION',
        v_start_ts,
        'IN_PROGRESS',
        'POSTGRES_SYSTEM'
    );

    -- 2. Population logic
    INSERT INTO db_tech_owner.resources_notif (
        snapshot_timestamp, tablespace_name, total_space_mb,
        used_space_mb, free_space_mb, usage_percentage,
        creation_date, created_by, source_system
    )
    SELECT
        NOW(),
        tablespace,
        total_mb,
        used_mb,
        free_mb,
        ROUND(used_mb * 100.0 / total_mb, 2),
        NOW(),
        'POSTGRES_SYSTEM',
        'db_env'
    FROM db_tech_owner.vw_tablespace_usage;  -- vezi pasul 2

    v_end_ts := NOW();

    -- 3. DONE
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'RESOURCES_NOTIF_POPULATION_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'POPULATION',
        v_start_ts,
        v_end_ts,
        'DONE',
        NULL,
        'POSTGRES_SYSTEM'
    );

EXCEPTION WHEN OTHERS THEN
    v_end_ts := NOW();
    v_error := SQLERRM;

    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'RESOURCES_NOTIF_POPULATION_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'POPULATION',
        v_start_ts,
        v_end_ts,
        'ERROR',
        v_error,
        'POSTGRES_SYSTEM'
    );

END;
$$;

\echo '===================================================';
\echo ' 13. PROGRAMARE JOB POPULARE RESOURCE_NOTIF TABLE  ';
\echo '===================================================';

SELECT cron.schedule(
    'job_population_resources_notif',
    '0 * * * *',  -- every hour
    $job$SELECT db_tech_owner.fn_population_resources_notif();$job$
);

\echo '==================================================';
\echo ' 14. CREATE FUNCTIE CLEANUP RESOURCES_NOTIF TABLE ';
\echo '==================================================';

CREATE OR REPLACE FUNCTION db_tech_owner.fn_cleanup_resources_notif()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_ts TIMESTAMP := NOW();
    v_end_ts   TIMESTAMP;
    v_deleted  INTEGER := 0;
    v_exists   INTEGER := 0;
    v_error    TEXT;
BEGIN
    -- 1. Verificăm dacă există rânduri de șters
    SELECT COUNT(*) INTO v_exists
    FROM db_tech_owner.resources_notif
    WHERE creation_date < NOW() - INTERVAL '3 days';

    -- Dacă nu există → ieșim fără notificări
    IF v_exists = 0 THEN
        RETURN;
    END IF;

    -- 2. IN_PROGRESS
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, status, admin_user
    ) VALUES (
        'RESOURCES_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        'IN_PROGRESS',
        'POSTGRES_SYSTEM'
    );

    -- 3. Cleanup logic
    DELETE FROM db_tech_owner.resources_notif
    WHERE creation_date < NOW() - INTERVAL '3 days';

    v_deleted := SQL%ROWCOUNT;
    v_end_ts := NOW();

    -- 4. DONE
    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'RESOURCES_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        v_end_ts,
        'DONE',
        'Deleted ' || v_deleted || ' rows older than 3 days',
        'POSTGRES_SYSTEM'
    );

EXCEPTION WHEN OTHERS THEN
    v_end_ts := NOW();
    v_error := SQLERRM;

    INSERT INTO db_tech_owner.processes_notif (
        process_name, process_date, process_type,
        start_timestamp, end_timestamp, status,
        error_message, admin_user
    ) VALUES (
        'RESOURCES_NOTIF_CLEAN_UP_PROCESS',
        TO_CHAR(NOW(), 'YYYY-MM-DD'),
        'CLEAN_UP',
        v_start_ts,
        v_end_ts,
        'ERROR',
        v_error,
        'POSTGRES_SYSTEM'
    );
END;
$$;

\echo '==================================================';
\echo ' 15. PROGRAMARE JOB CLEANUP RESOURCE_NOTIF TABLE  ';
\echo '==================================================';

SELECT cron.schedule(
    'job_cleanup_resources_notif',
    '0 3 * * *',
    $job$SELECT db_tech_owner.fn_cleanup_resources_notif();$job$
);

\echo '=== END INIT SCRIPT 02_pg_db_tech_owner.sql ==='