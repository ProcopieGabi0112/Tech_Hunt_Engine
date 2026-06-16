package com.techhunter.tech_hunter_engine_api.repository.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.InstitutionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InstitutionRepository extends JpaRepository<InstitutionEntity, Long> {

    List<InstitutionEntity> findByLocation_LocationId(Long locationId);
}
