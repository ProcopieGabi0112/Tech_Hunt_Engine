/*ORACLE VERSION*/
WITH view_map AS (
    SELECT 
        LOWER(view_name) AS view_name
    FROM all_views
    WHERE owner = 'AUTONOMOUS_DB_OUT_OWNER'
),
table_classification AS (
    SELECT column_value AS table_name
    FROM TABLE(sys.odcivarchar2list(
        'utilizatori',
        'email',
        'user_spec',
        'user_level',
        'company',
        'department',
        'job',
        'language_requirement',
        'degree_requirement',
        'job_skill',
        'user_skill',
        'job_application',
        'job_history',
        'review'
    ))
),
row_counts AS (
    SELECT 
        owner,
        table_name,
        num_rows
    FROM all_tab_statistics
)
SELECT
    ROW_NUMBER() OVER (ORDER BY t.owner, t.table_name) AS "No.",
    t.owner AS "Schema_Name",
    t.table_name AS "Table_Name",
    c.comments AS "Table_Description",

    /* EXPOSE TO — caută view-ul cu numele <table>_v */
    (
        SELECT 'autonomous_db_out_owner.' || v.view_name
        FROM view_map v
        WHERE v.view_name = LOWER(t.table_name) || '_v'
        FETCH FIRST 1 ROWS ONLY
    ) AS "Expose To",

    /* TABLE TYPE — clasificare automată */
    CASE
        WHEN LOWER(t.table_name) LIKE '%\_notif' ESCAPE '\' THEN 'TECHNICAL_TABLE'
        WHEN EXISTS (
            SELECT 1 FROM table_classification tc 
            WHERE tc.table_name = LOWER(t.table_name)
        ) THEN 'TRANSACTIONAL_TABLE'
        ELSE 'NOMENCLATOR_TABLE'
    END AS "Table_Type",

    /* TOTAL RECORDS — num_rows din statistici */
    NVL(rc.num_rows, 0) AS "Total_Records",

    'PRODUCTION' AS "Table_Status"

FROM all_tables t
LEFT JOIN all_tab_comments c
    ON t.owner = c.owner 
   AND t.table_name = c.table_name
LEFT JOIN row_counts rc
    ON rc.owner = t.owner
   AND rc.table_name = t.table_name
WHERE t.owner LIKE '%OWNER%'
AND t.table_name <> 'DBTOOLS$EXECUTION_HISTORY'
ORDER BY t.owner, t.table_name;

/*POSTGRES_VERSION*/
WITH view_map AS (
    SELECT 
        LOWER(table_name) AS view_name
    FROM information_schema.views
    WHERE table_schema = 'db_out_owner'
),
table_classification AS (
    SELECT unnest(ARRAY[
        'utilizatori',
        'email',
        'user_spec',
        'user_level',
        'company',
        'department',
        'job',
        'language_requirement',
        'degree_requirement',
        'job_skill',
        'user_skill',
        'job_application',
        'job_history',
        'review'
    ]) AS table_name
),
row_counts AS (
    SELECT 
        table_schema,
        table_name,
        (xpath('/row/cnt/text()', xml_count))[1]::text::bigint AS row_count
    FROM (
        SELECT 
            table_schema,
            table_name,
            query_to_xml(format('SELECT COUNT(*) AS cnt FROM %I.%I', table_schema, table_name), false, true, '') AS xml_count
        FROM information_schema.tables
        WHERE table_schema LIKE '%owner%'
    ) x
)
SELECT
    ROW_NUMBER() OVER (ORDER BY t.table_schema, t.table_name) AS "No.",
    t.table_schema AS "Schema_Name",
    t.table_name AS "Table_Name",
    obj_description((t.table_schema||'.'||t.table_name)::regclass) AS "Table_Description",

    /* EXPOSE TO — caută view-ul cu numele <table>_v */
    (
        SELECT 'db_out_owner.' || v.view_name
        FROM view_map v
        WHERE v.view_name = LOWER(t.table_name) || '_v'
        LIMIT 1
    ) AS "Expose To",

    /* TABLE TYPE — clasificare automată */
    CASE
        WHEN LOWER(t.table_name) LIKE '%_notif' THEN 'TECHNICAL_TABLE'
        WHEN EXISTS (
            SELECT 1 FROM table_classification tc
            WHERE tc.table_name = LOWER(t.table_name)
        ) THEN 'TRANSACTIONAL_TABLE'
        ELSE 'NOMENCLATOR_TABLE'
    END AS "Table_Type",

    /* TOTAL RECORDS — COUNT(*) real */
    COALESCE(rc.row_count, 0) AS "Total_Records",

    'PRODUCTION' AS "Table_Status"

FROM information_schema.tables t
LEFT JOIN row_counts rc
    ON rc.table_schema = t.table_schema
   AND rc.table_name = t.table_name
WHERE t.table_schema LIKE '%owner%'
  AND t.table_name <> 'dbtools$execution_history'
ORDER BY t.table_schema, t.table_name;