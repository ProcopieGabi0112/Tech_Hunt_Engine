package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationDTO;

import java.util.List;

public interface SpecializationService {
    List<SpecializationDTO> getSpecializationsByInstitution(Long institutionId);
}