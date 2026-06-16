package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.InstitutionDTO;

import java.util.List;

public interface InstitutionService {
    List<InstitutionDTO> getInstitutionsByLocation(Long locationId);
}