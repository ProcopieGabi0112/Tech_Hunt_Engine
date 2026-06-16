package com.techhunter.tech_hunter_engine_api.dto.postgres.location;

public record AdministrativeUnitDTO(
        Long administrativeUnitId,
        String name,
        String code,
        Long population,
        Long area,
        Long numberOfCities,
        String description,
        Long administrativeUnitTypeId,
        String administrativeUnitTypeName,   // <-- ADĂUGAT
        Long countryId
) {}
