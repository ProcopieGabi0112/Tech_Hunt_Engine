\echo '=== START INIT SCRIPT 01_pg_admin.sql ==='

-- =====================================================
-- 1. CREARE USERI FUNCTIONALI
-- =====================================================
CREATE ROLE db_tech_owner WITH LOGIN PASSWORD 'DbTechOwnerPass';
CREATE ROLE db_ds_owner  WITH LOGIN PASSWORD 'DbDsOwnerPass';

-- =====================================================
-- 2. CREARE SCHEME
-- =====================================================
CREATE SCHEMA IF NOT EXISTS db_tech_owner AUTHORIZATION db_tech_owner;
CREATE SCHEMA IF NOT EXISTS db_ds_owner  AUTHORIZATION db_ds_owner;

-- =====================================================
-- 3. SETARE SEARCH PATH
-- =====================================================
ALTER ROLE db_tech_owner SET search_path = db_tech_owner, public;
ALTER ROLE db_ds_owner  SET search_path = db_ds_owner, public;

-- =====================================================
-- 4. PERMISIUNI MINIME (corecte)
-- =====================================================

-- db_ds_owner poate doar citi configurările
GRANT USAGE ON SCHEMA db_tech_owner TO db_ds_owner;
GRANT SELECT ON ALL TABLES IN SCHEMA db_tech_owner TO db_ds_owner;
ALTER DEFAULT PRIVILEGES IN SCHEMA db_tech_owner GRANT SELECT ON TABLES TO db_ds_owner;

-- db_tech_owner poate doar citi modelele
GRANT USAGE ON SCHEMA db_ds_owner TO db_tech_owner;
GRANT SELECT ON ALL TABLES IN SCHEMA db_ds_owner TO db_tech_owner;
ALTER DEFAULT PRIVILEGES IN SCHEMA db_ds_owner GRANT SELECT ON TABLES TO db_tech_owner;

\echo '=== END INIT SCRIPT 01_pg_admin.sql ==='
