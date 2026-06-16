package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

public record CompanyPublicDTO(
        Long companyId,
        String name,
        String description,
        String website,
        String industryTypeName,
        String companyTypeName,
        Long countryId,
        Long administrativeUnitTypeId,
        Long administrativeUnitId,
        Long cityId,
        String cityName,
        Long noEmployees,
        String foundationDate,
        String rating,
        byte[] profileImage
) {}