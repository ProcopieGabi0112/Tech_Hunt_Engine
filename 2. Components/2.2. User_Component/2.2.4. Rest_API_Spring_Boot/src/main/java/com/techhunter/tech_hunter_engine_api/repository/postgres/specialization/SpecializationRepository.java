package com.techhunter.tech_hunter_engine_api.repository.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SpecializationRepository extends JpaRepository<SpecializationEntity, Long> {

    List<SpecializationEntity> findByInstitution_InstitutionId(Long institutionId);
}
