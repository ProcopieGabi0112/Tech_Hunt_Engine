package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

public record OrganizationTypeDTO(
        Long companyTypeId,
        String name,
        String code,
        String description
) {}
