package com.techhunter.tech_hunter_engine_api.repository.postgres.certification;

import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LanguageEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LanguageRepository extends JpaRepository<LanguageEntity, Long> {
}
