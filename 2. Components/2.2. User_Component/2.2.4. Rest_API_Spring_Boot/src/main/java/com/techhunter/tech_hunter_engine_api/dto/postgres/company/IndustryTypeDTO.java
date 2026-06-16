package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

public record IndustryTypeDTO(
        Long industryTypeId,
        String name,
        String code,
        String description
) {}
