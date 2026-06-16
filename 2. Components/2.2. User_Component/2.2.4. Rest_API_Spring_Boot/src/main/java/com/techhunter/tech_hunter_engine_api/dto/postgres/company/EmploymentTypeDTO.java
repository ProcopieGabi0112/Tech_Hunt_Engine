package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

import java.math.BigDecimal;

public record EmploymentTypeDTO(
        Long employmentTypeId,
        String name,
        BigDecimal complexityScore,
        String code,
        String description
) {}
