package com.techhunter.tech_hunter_engine_api.dto.postgres.location;

public record RegionDTO(
        Long regionId,
        String name,
        String code,
        String description
) {}
