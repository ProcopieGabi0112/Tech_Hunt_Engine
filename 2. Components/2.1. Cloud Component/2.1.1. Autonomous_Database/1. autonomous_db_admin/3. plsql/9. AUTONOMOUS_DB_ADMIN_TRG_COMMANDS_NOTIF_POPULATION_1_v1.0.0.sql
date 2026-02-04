CREATE OR REPLACE TRIGGER trg_commands_notif_on_<TABLE_NAME>
AFTER INSERT OR UPDATE OR DELETE ON autonomous_db_owner.<TABLE_NAME>
FOR EACH ROW
DECLARE
  v_action        VARCHAR2(30);
  v_sql_command   VARCHAR2(4000);

-- Funcție utilă pentru escape la apostrofuri 
FUNCTION esc(p_str VARCHAR2) RETURN VARCHAR2 IS 
BEGIN RETURN REPLACE(p_str, '''', ''''''); END; 
BEGIN
------------------------------------------------------------------- 
-- INSERT 
-------------------------------------------------------------------
  -- Determinăm acțiunea
  IF INSERTING THEN
    v_action := 'INSERT';
    v_sql_command := 'INSERT INTO MY_TABLE (ID, NAME, STATUS, AMOUNT, CREATED_DATE, UPDATED_TS) VALUES (' || 
    -- NUMBER 
    NVL(TO_CHAR(:NEW.ID), 'NULL') || ', ' || 
    -- VARCHAR2 
    CASE WHEN :NEW.NAME IS NULL THEN 'NULL' ELSE '''' || esc(:NEW.NAME) || '''' END || ', ' || 
    CASE WHEN :NEW.STATUS IS NULL THEN 'NULL' ELSE '''' || esc(:NEW.STATUS) || '''' END || ', ' || 
    -- NUMBER(10,2) 
    NVL(TO_CHAR(:NEW.AMOUNT), 'NULL') || ', ' || 
    -- DATE 
    CASE WHEN :NEW.CREATED_DATE IS NULL THEN 'NULL' ELSE 'TO_DATE(''' || TO_CHAR(:NEW.CREATED_DATE,'YYYY-MM-DD HH24:MI:SS') || ''',''YYYY-MM-DD HH24:MI:SS'')' END || ', ' || 
    -- TIMESTAMP 
    CASE WHEN :NEW.UPDATED_TS IS NULL THEN 'NULL' ELSE 'TO_TIMESTAMP(''' || TO_CHAR(:NEW.UPDATED_TS,'YYYY-MM-DD HH24:MI:SS.FF') || ''',''YYYY-MM-DD HH24:MI:SS.FF'')' END || ')';
  ------------------------------------------------------------------- 
  -- UPDATE 
  -------------------------------------------------------------------
  ELSIF UPDATING THEN v_action := 'UPDATE'; v_sql_command := 'UPDATE MY_TABLE SET ' || -- NUMBER 'ID=' || NVL(TO_CHAR(:NEW.ID), 'NULL') || ', ' || -- VARCHAR2 'NAME=' || CASE WHEN :NEW.NAME IS NULL THEN 'NULL' ELSE '''' || esc(:NEW.NAME) || '''' END || ', ' || 'STATUS=' || CASE WHEN :NEW.STATUS IS NULL THEN 'NULL' ELSE '''' || esc(:NEW.STATUS) || '''' END || ', ' || -- NUMBER(10,2) 'AMOUNT=' || NVL(TO_CHAR(:NEW.AMOUNT), 'NULL') || ', ' || -- DATE 'CREATED_DATE=' || CASE WHEN :NEW.CREATED_DATE IS NULL THEN 'NULL' ELSE 'TO_DATE(''' || TO_CHAR(:NEW.CREATED_DATE,'YYYY-MM-DD HH24:MI:SS') || ''',''YYYY-MM-DD HH24:MI:SS'')' END || ', ' || -- TIMESTAMP 'UPDATED_TS=' || CASE WHEN :NEW.UPDATED_TS IS NULL THEN 'NULL' ELSE 'TO_TIMESTAMP(''' || TO_CHAR(:NEW.UPDATED_TS,'YYYY-MM-DD HH24:MI:SS.FF') || ''',''YYYY-MM-DD HH24:MI:SS.FF'')' END || ' WHERE ID=' || NVL(TO_CHAR(:OLD.ID), 'NULL');
  ------------------------------------------------------------------- 
  -- DELETE 
  -------------------------------------------------------------------
  ELSIF DELETING THEN v_action := 'DELETE'; v_sql_command := 'DELETE FROM MY_TABLE WHERE ID=' || NVL(TO_CHAR(:OLD.ID), 'NULL'); END IF;

    -- Inserăm în tabela de audit
  INSERT INTO autonomous_db_tech_owner.commands_notif (
    comm_audit_key,
    user_name,
    command_timestamp,
    sql_command,
    command_type,
    schema,
    created_by,
    source_system
  ) VALUES (
    SYS_GUID(),                                             -- cheie unică
    USER,                                                   -- userul care a executat comanda
    SYSTIMESTAMP,                                           -- timestamp
    v_sql_command,                                          -- comanda generică
    v_action,                                               -- tipul comenzii
    'AUTONOMOUS_DB_OWNER',                                  -- schema
    'AUTONOMOUS_DATABASE_SYSTEM',                           -- created_by
    'db_env'                                                -- source_system
  );
END;
/
