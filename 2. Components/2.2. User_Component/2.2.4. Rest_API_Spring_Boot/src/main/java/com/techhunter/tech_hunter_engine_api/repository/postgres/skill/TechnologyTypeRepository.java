package com.techhunter.tech_hunter_engine_api.repository.postgres.skill;

import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TechnologyTypeRepository extends JpaRepository<TechnologyTypeEntity, Long> {
}
