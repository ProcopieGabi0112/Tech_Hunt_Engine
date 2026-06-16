package com.techhunter.tech_hunter_engine_api.repository.postgres.skill;

import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TechnologyRepository extends JpaRepository<TechnologyEntity, Long> {

    List<TechnologyEntity> findByTechnologyType_TechnologyTypeCode(Long technologyTypeCode);
}
