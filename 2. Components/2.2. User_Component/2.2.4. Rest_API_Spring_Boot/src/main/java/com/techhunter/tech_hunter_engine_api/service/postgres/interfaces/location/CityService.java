package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CityDTO;

import java.util.List;

public interface CityService {
    List<CityDTO> getCitiesByAdministrativeUnit(Long administrativeUnitId);
}