package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

import java.math.BigDecimal;

public record JobTitleDTO(
        Long jobTitleId,
        String name,
        BigDecimal complexityScore,
        String code,
        String description
) {}
