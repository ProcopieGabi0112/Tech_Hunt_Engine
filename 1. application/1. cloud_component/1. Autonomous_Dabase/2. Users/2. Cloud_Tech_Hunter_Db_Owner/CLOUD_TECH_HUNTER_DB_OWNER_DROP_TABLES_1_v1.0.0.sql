BEGIN
  FOR t IN (
    SELECT table_name
    FROM all_tables
    WHERE owner = UPPER('TECH_HUNTER_DB_OWNER')
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ' || '"' || t.table_name || '"' || ' CASCADE CONSTRAINTS';
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare la ștergerea tabelului ' || t.table_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/