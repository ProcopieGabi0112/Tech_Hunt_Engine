package com.techhunter.tech_hunter_engine_api.dto.postgres.specialization;

public record InstitutionDTO(
        Long institutionId,
        String name,
        String website,
        String foundingYear,
        Double rating,
        String description,
        Long locationId
) {}