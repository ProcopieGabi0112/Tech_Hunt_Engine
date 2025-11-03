BEGIN
  -- 1️⃣ Ștergem mai întâi toate constrângerile
  FOR cons IN (
    SELECT table_name, constraint_name
    FROM all_constraints
    WHERE owner = UPPER('TECH_HUNTER_DB_OWNER')
      AND constraint_type IN ('R', 'P', 'U', 'C') -- FK, PK, Unique, Check
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE "' || cons.table_name || '" DROP CONSTRAINT "' || cons.constraint_name || '" CASCADE';
      DBMS_OUTPUT.PUT_LINE('Șters constraint ' || cons.constraint_name || ' din tabela ' || cons.table_name);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare la ștergerea constraint ' || cons.constraint_name || ': ' || SQLERRM);
    END;
  END LOOP;

  -- 2️⃣ Apoi ștergem toate celelalte obiecte din schemă
  FOR obj IN (
    SELECT object_type, object_name
    FROM all_objects
    WHERE owner = UPPER('TECH_HUNTER_DB_OWNER')
      AND object_type IN (
        'TABLE', 'VIEW', 'SEQUENCE', 'TRIGGER', 'PROCEDURE', 'FUNCTION',
        'PACKAGE', 'PACKAGE BODY', 'SYNONYM', 'MATERIALIZED VIEW', 'TYPE'
      )
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' "' || obj.object_name || '"' ||
        CASE obj.object_type
          WHEN 'TABLE' THEN ' CASCADE CONSTRAINTS'
          WHEN 'TYPE' THEN ' FORCE'
          ELSE ''
        END;
      DBMS_OUTPUT.PUT_LINE('Șters ' || obj.object_type || ' ' || obj.object_name);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare la ștergerea ' || obj.object_type || ' ' || obj.object_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/
