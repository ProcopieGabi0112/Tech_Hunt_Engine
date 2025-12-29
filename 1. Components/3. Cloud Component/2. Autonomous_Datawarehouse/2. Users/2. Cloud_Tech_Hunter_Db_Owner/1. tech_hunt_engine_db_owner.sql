--verificam daca tabela exista
DROP TABLE tech_hunter_db_owner.lang_level;
DROP TABLE tech_hunter_db_owner.language;
--cream tabela LANGUAGE
CREATE TABLE tech_hunter_db_owner.language (
  lang_code             NUMBER(38,0) PRIMARY KEY,
  name                  VARCHAR2(60) NOT NULL,
  iso_code              VARCHAR2(5) NOT NULL,
  no_native_speakers    NUMBER(20,0) NOT NULL,
  no_speakers           NUMBER(38,0) NOT NULL,
  no_countries          NUMBER(5,0) NOT NULL,
  rating                NUMBER(5,2) GENERATED ALWAYS AS (
                          ROUND((
                            0.4 * LOG(10, no_native_speakers + 1) +
                            0.5 * LOG(10, no_speakers + 1) +
                            0.1 * SQRT(no_countries)
                          ) / 9.2 * 100, 2)
                        ) VIRTUAL,
  creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  created_by            VARCHAR2(50) NOT NULL,
  last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  last_updated_by       VARCHAR2(50) NOT NULL,
  source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
  sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
  sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
  last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL
);

-- Comentariu pe tabelă
COMMENT ON TABLE tech_hunter_db_owner.language IS 'The table contains the spoken languages of students';
-- Comentarii pe coloane
COMMENT ON COLUMN tech_hunter_db_owner.language.lang_code IS 'The primary key of the language table';
COMMENT ON COLUMN tech_hunter_db_owner.language.name IS 'The name of the language';
COMMENT ON COLUMN tech_hunter_db_owner.language.iso_code IS 'The ISO code of the language';
COMMENT ON COLUMN tech_hunter_db_owner.language.no_native_speakers IS 'The number of native speakers';
COMMENT ON COLUMN tech_hunter_db_owner.language.no_speakers IS 'The number of speakers';
COMMENT ON COLUMN tech_hunter_db_owner.language.no_countries IS 'The number of countries where you can speak this language';
COMMENT ON COLUMN tech_hunter_db_owner.language.rating IS 'The rating of this language, calculated based on speakers and country spread';
COMMENT ON COLUMN tech_hunter_db_owner.language.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN tech_hunter_db_owner.language.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN tech_hunter_db_owner.language.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

DROP SEQUENCE seq_language_id;

CREATE SEQUENCE seq_language_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER trg_language_id
BEFORE INSERT ON tech_hunter_db_owner.language
FOR EACH ROW
WHEN (NEW.lang_code IS NULL)
BEGIN
  SELECT seq_language_id.NEXTVAL INTO :NEW.lang_code FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_language_audit
BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.language
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.created_by := USER;
    :NEW.last_updated_by := USER;
    :NEW.creation_date := CURRENT_TIMESTAMP;
    :NEW.last_update_date := CURRENT_TIMESTAMP;
  END IF;

  IF UPDATING THEN
    :NEW.last_update_date := CURRENT_TIMESTAMP;
    :NEW.last_updated_by := USER;
  END IF;
END;
/

--verificam daca tabela exista
DROP TABLE tech_hunter_db_owner.lang_level;
--cream tabela LANGUAGE
CREATE TABLE tech_hunter_db_owner.lang_level (
  lang_level_id NUMBER(38,0) PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  nivel VARCHAR2(30) NOT NULL,
  lang_code NUMBER(38,0) NOT NULL,
  validity_period NUMBER(3,0) DEFAULT 0,
  rating NUMBER(5,2) DEFAULT 0,
  description VARCHAR2(100),
  creation_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  created_by            VARCHAR2(50) NOT NULL,
  last_update_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  last_updated_by       VARCHAR2(50) NOT NULL,
  source_system         VARCHAR2(20) DEFAULT 'cloud_env' NOT NULL,
  sync_status           VARCHAR2(20) DEFAULT 'synced' NOT NULL,
  sync_version          NUMBER(38,0) DEFAULT 1 NOT NULL,
  last_synced_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_flag          VARCHAR2(5) DEFAULT 'N' NOT NULL,
  CONSTRAINT fk_lang_code
        FOREIGN KEY (lang_code)
        REFERENCES language(lang_code)
        ON DELETE CASCADE
);

-- Comentariu pe tabelă
COMMENT ON TABLE tech_hunter_db_owner.lang_level IS 'The table contains the certifications of every language that the students can have';
-- Comentarii pe coloane
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.lang_level_id IS 'The primary key of the lang level table';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.name IS 'The name of the certification';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.nivel IS 'The level of the certification';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.lang_code IS 'The language of the certification';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.validity_period IS 'The validity period of the certification (in months)';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.rating IS 'The rating of this certification, calculated based on the number of students that consider this certification is helpfull.';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.description IS 'The description of the certification';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.creation_date IS 'Technical Column - The creation date of the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.created_by IS 'Technical Column - The user who created the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.last_update_date IS 'Technical Column - The last update date of the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.last_updated_by IS 'Technical Column - The user who updated the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.source_system IS 'Technical Column - The source system of the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.sync_status IS 'Technical Column - The sync status of the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.sync_version IS 'Technical Column - The sync version of the record';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.last_synced_at IS 'Technical Column - The date when the record was last time synced';
COMMENT ON COLUMN tech_hunter_db_owner.lang_level.deleted_flag IS 'Technical Column - The flag indicating if the record is deleted or not';

DROP SEQUENCE seq_lang_level_id;

CREATE SEQUENCE seq_lang_level_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER trg_lang_level_id
BEFORE INSERT ON tech_hunter_db_owner.lang_level
FOR EACH ROW
WHEN (NEW.lang_level_id IS NULL)
BEGIN
  SELECT seq_lang_level_id.NEXTVAL INTO :NEW.lang_level_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_lang_level_audit
BEFORE INSERT OR UPDATE ON tech_hunter_db_owner.lang_level
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.created_by := USER;
    :NEW.last_updated_by := USER;
    :NEW.creation_date := CURRENT_TIMESTAMP;
    :NEW.last_update_date := CURRENT_TIMESTAMP;
  END IF;

  IF UPDATING THEN
    :NEW.last_update_date := CURRENT_TIMESTAMP;
    :NEW.last_updated_by := USER;
  END IF;
END;
/