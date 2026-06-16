package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.RegionDTO;

import java.util.List;

public interface RegionService {
    List<RegionDTO> getAllRegions();
}
