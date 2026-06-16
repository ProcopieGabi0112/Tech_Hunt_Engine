package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitDTO;

import java.util.List;

public interface AdministrativeUnitService {
    List<AdministrativeUnitDTO> getUnitsByCountry(Long countryId);
}