/*ORACLE VERSION*/
WITH pk_cols AS (
    SELECT DISTINCT acc.owner, acc.table_name, acc.column_name
    FROM all_constraints ac
    JOIN all_cons_columns acc 
        ON ac.owner = acc.owner 
       AND ac.constraint_name = acc.constraint_name
    WHERE ac.constraint_type = 'P'
),
fk_info AS (
    SELECT 
        acc.owner,
        acc.table_name,
        acc.column_name,
        ac_r.table_name AS ref_table,
        acc_r.column_name AS ref_column
    FROM all_constraints ac
    JOIN all_cons_columns acc
        ON ac.owner = acc.owner
       AND ac.constraint_name = acc.constraint_name
    JOIN all_constraints ac_r
        ON ac.r_owner = ac_r.owner
       AND ac.r_constraint_name = ac_r.constraint_name
    JOIN all_cons_columns acc_r
        ON ac_r.owner = acc_r.owner
       AND ac_r.constraint_name = acc_r.constraint_name
       AND acc.position = acc_r.position
    WHERE ac.constraint_type = 'R'
),
check_cols AS (
    SELECT DISTINCT 
        acc.owner,
        acc.table_name,
        acc.column_name
    FROM all_constraints ac
    JOIN all_cons_columns acc
        ON ac.owner = acc.owner
       AND ac.constraint_name = acc.constraint_name
    WHERE ac.constraint_type = 'C'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY col.owner, col.table_name, col.column_id) AS "No.",
    col.owner AS "Schema_Name",
    col.table_name AS "Table_Name",
    col.column_name AS "Column_Name",

    col.data_type ||
        CASE 
            WHEN col.data_type LIKE '%CHAR%' THEN '(' || col.char_length || ')'
            WHEN col.data_type = 'NUMBER' AND col.data_precision IS NOT NULL THEN '(' || col.data_precision || ',' || col.data_scale || ')'
        END AS "Column_Datatype",

    com.comments AS "Column_Description",

    /* COLUMN TYPE: TECHNICAL vs BUSINESS */
    CASE 
        WHEN LOWER(col.column_name) IN (
            'creation_date',
            'created_by',
            'last_update_date',
            'last_updated_by',
            'source_system',
            'sync_status',
            'sync_version',
            'last_synced_at',
            'deleted_flag'
        ) THEN 'TECHNICAL'
        ELSE 'BUSINESS'
    END AS "Column_Type",

    /* PRIMARY KEY */
    CASE WHEN pk.column_name IS NOT NULL THEN 'Y' ELSE 'N' END AS "Primary_Key",

    /* FOREIGN KEY: Y [table:column] */
    CASE 
        WHEN fk.ref_table IS NOT NULL THEN 
            'Y [' || LOWER(fk.ref_table) || ':' || LOWER(fk.ref_column) || ']'
        ELSE 'N'
    END AS "Foreign_Key",

    /* NULLABLE */
    CASE WHEN col.nullable = 'Y' THEN 'Y' ELSE 'N' END AS "Nullable",

    /* DEFAULT VALUE */
    col.data_default AS "Default_Value",

    /* POSSIBLE VALUES — LONG restriction → NULL */
    NULL AS "Possible_Values",

    /* COLUMN GENERATION FLAG */
    CASE 
        WHEN col.virtual_column = 'YES' THEN 'Y'
        ELSE 'N'
    END AS "Column_Generation",

    /* FORMULA REALĂ PENTRU GENERATED COLUMNS */
    CASE 
        WHEN col.virtual_column = 'YES' THEN col.data_default
        ELSE NULL
    END AS "Generation_Method",

    'PRODUCTION' AS "Table_Status"

FROM all_tab_cols col
LEFT JOIN all_col_comments com
    ON col.owner = com.owner
   AND col.table_name = com.table_name
   AND col.column_name = com.column_name
LEFT JOIN pk_cols pk
    ON col.owner = pk.owner
   AND col.table_name = pk.table_name
   AND col.column_name = pk.column_name
LEFT JOIN fk_info fk
    ON col.owner = fk.owner
   AND col.table_name = fk.table_name
   AND col.column_name = fk.column_name
LEFT JOIN check_cols cc
    ON col.owner = cc.owner
   AND col.table_name = cc.table_name
   AND col.column_name = cc.column_name
WHERE col.owner LIKE '%DB_OWNER%'
ORDER BY col.owner, col.table_name, col.column_id;


/*POSTGRES_VERSION*/
