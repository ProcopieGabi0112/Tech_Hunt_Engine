package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.LocationDTO;

import java.util.List;

public interface LocationService {
    List<LocationDTO> getLocationsByCity(Long cityCode);
}