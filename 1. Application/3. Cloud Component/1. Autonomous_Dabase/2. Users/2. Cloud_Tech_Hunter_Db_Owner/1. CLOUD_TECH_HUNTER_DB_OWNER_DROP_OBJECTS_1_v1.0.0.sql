SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE('===== DROP OBJECTS FROM TECH_HUNTER_DB_OWNER =====');

  -- 1️⃣ Ștergem mai întâi toate constrângerile (FK, PK, UNIQUE, CHECK)
  FOR cons IN (
    SELECT table_name, constraint_name
    FROM user_constraints
    WHERE owner = UPPER('TECH_HUNTER_DB_OWNER')
      AND constraint_type IN ('R', 'P', 'U', 'C')
      AND table_name IN ( 'LANG_LEVEL')
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE "' || cons.table_name || '" DROP CONSTRAINT "' || cons.constraint_name || '" CASCADE';
      DBMS_OUTPUT.PUT_LINE('Delete  constraint ' || cons.constraint_name || ' din tabela ' || cons.table_name);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare la ștergerea constraint ' || cons.constraint_name || ': ' || SQLERRM);
    END;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Toate constrângerile au fost procesate.');

  -- 2️⃣ Ștergem toate celelalte obiecte (inclusiv PACKAGE BODY)
  FOR obj IN (
    SELECT object_type, object_name
    FROM all_objects
    WHERE owner = UPPER('TECH_HUNTER_DB_OWNER')
      AND object_type IN (
        'VIEW', 'MATERIALIZED VIEW', 'TRIGGER', 'PROCEDURE', 'FUNCTION',
        'PACKAGE BODY', 'PACKAGE', 'SEQUENCE', 'SYNONYM', 'TYPE', 'TABLE'
      )
    ORDER BY DECODE(object_type, 'TRIGGER', 1, 'VIEW', 2, 'TABLE', 3, 4) -- mică prioritate logică
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' "' || obj.object_name || '"' ||
        CASE obj.object_type
          WHEN 'TABLE' THEN ' CASCADE CONSTRAINTS'
          WHEN 'TYPE' THEN ' FORCE'
          ELSE ''
        END;
      DBMS_OUTPUT.PUT_LINE('Delete ' || obj.object_type || ' ' || obj.object_name);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare la ștergerea ' || obj.object_type || ' ' || obj.object_name || ': ' || SQLERRM);
    END;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('===== Curătarea completă a fost finalizată =====');
END;
/

