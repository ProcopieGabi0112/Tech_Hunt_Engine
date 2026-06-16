package com.techhunter.tech_hunter_engine_api.repository.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SpecializationTypeRepository extends JpaRepository<SpecializationTypeEntity, Long> {
}
