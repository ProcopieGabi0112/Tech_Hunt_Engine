package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CountryDTO;

import java.util.List;

public interface CountryService {
    List<CountryDTO> getCountriesByRegion(Long regionId);
}