package com.techhunter.tech_hunter_engine_api.dto.postgres.location;

public record CountryDTO(
        Long countryId,
        String name,
        String code,
        Long population,
        Long area,
        String timeZone,
        Double unemploymentRate,
        Double inflationRate,
        Double averageMonthlySalary,
        Double corporateTaxRate,
        Double rating,
        Long regionId,
        Long languageId,
        Long currencyId
) {}
