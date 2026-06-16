package com.techhunter.tech_hunter_engine_api.dto.postgres.location;

public record CityDTO(
        Long cityCode,
        String name,
        Long population,
        Long area,
        String isCapital,
        Double latitude,
        Double longitude,
        String description,
        Long administrativeUnitId
) {}