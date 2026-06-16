package com.techhunter.tech_hunter_engine_api.repository.postgres.certification;

import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LangLevelEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LangLevelRepository extends JpaRepository<LangLevelEntity, Long> {

    List<LangLevelEntity> findByLanguage_LangCode(Long langCode);
}
