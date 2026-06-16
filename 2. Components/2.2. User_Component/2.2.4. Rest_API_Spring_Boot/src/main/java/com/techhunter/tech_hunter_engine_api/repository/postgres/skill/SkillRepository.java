package com.techhunter.tech_hunter_engine_api.repository.postgres.skill;

import com.techhunter.tech_hunter_engine_api.model.postgres.skill.SkillEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SkillRepository extends JpaRepository<SkillEntity, Long> {
    List<SkillEntity> findByLastVersion_Technology_TechnologyCode(Long technologyCode);
    List<SkillEntity> findByLastVersion_VersionCode(Long versionCode);
}
