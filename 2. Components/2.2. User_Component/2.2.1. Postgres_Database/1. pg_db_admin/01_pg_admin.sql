\echo '=== START INIT SCRIPT 01_pg_admin.sql ==='
-- =====================================================
-- SCRIPT ADMIN - SETUP COMPLET UTILIZATORI + SCHEME + ACCESS
-- =====================================================

-- =====================================================
-- 1. CREARE USERI
-- =====================================================
CREATE ROLE db_tech_owner WITH LOGIN PASSWORD 'DbTechOwnerPass';
CREATE ROLE db_owner WITH LOGIN PASSWORD 'DbOwnerPass';
CREATE ROLE db_out_owner WITH LOGIN PASSWORD 'DbOutOwnerPass';


-- =====================================================
-- 2. CREARE SCHEME
-- =====================================================
CREATE SCHEMA db_tech_owner AUTHORIZATION db_tech_owner;
CREATE SCHEMA db_owner AUTHORIZATION db_owner;
CREATE SCHEMA db_out_owner AUTHORIZATION db_out_owner;


-- =====================================================
-- 3. SETARE SEARCH PATH (opțional dar recomandat)
-- =====================================================
ALTER ROLE db_tech_owner SET search_path TO db_tech_owner;
ALTER ROLE db_owner SET search_path TO db_owner;
ALTER ROLE db_out_owner SET search_path TO db_out_owner;


-- =====================================================
-- 4. PERMISIUNI PENTRU db_tech_owner (rol tehnic extins)
-- =====================================================

-- acces la scheme
GRANT ALL ON SCHEMA db_owner TO db_tech_owner;
GRANT ALL ON SCHEMA db_out_owner TO db_tech_owner;

-- acces la tabele existente
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA db_owner TO db_tech_owner;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA db_out_owner TO db_tech_owner;

-- acces pe viitor (foarte important)
ALTER DEFAULT PRIVILEGES IN SCHEMA db_owner
GRANT ALL ON TABLES TO db_tech_owner;

ALTER DEFAULT PRIVILEGES IN SCHEMA db_out_owner
GRANT ALL ON TABLES TO db_tech_owner;

-- =====================================================
-- 5. MESAJE DE DEBUG (utile la init)
-- =====================================================
\echo '=== END INIT SCRIPT 01_pg_admin.sql ==='