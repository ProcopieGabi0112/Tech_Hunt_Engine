BEGIN
  FOR obj IN (
    SELECT object_type, object_name
    FROM all_objects
    WHERE owner = UPPER('TECH_HUNTER_DB_OWNER')
      AND object_type IN (
        'TABLE', 'VIEW', 'SEQUENCE', 'TRIGGER', 'PROCEDURE', 'FUNCTION',
        'PACKAGE', 'SYNONYM', 'MATERIALIZED VIEW', 'TYPE'
      )
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' "' || obj.object_name || '"' ||
        CASE obj.object_type
          WHEN 'TABLE' THEN ' CASCADE CONSTRAINTS'
          WHEN 'TYPE' THEN ' FORCE'
          ELSE ''
        END;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare la ștergerea ' || obj.object_type || ' ' || obj.object_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/
