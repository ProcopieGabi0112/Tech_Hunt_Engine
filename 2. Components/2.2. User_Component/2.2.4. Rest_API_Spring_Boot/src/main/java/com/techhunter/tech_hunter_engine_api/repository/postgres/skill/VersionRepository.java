package com.techhunter.tech_hunter_engine_api.repository.postgres.skill;

import com.techhunter.tech_hunter_engine_api.model.postgres.skill.VersionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VersionRepository extends JpaRepository<VersionEntity, Long> {
    List<VersionEntity> findByTechnology_TechnologyCode(Long technologyCode);
}
