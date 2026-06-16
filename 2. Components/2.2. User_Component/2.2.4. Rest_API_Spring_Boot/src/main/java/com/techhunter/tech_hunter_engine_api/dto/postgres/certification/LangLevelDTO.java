package com.techhunter.tech_hunter_engine_api.dto.postgres.certification;

import java.math.BigDecimal;

public record LangLevelDTO(
        Long langLevelId,
        String name,
        String nivel,
        BigDecimal rating,
        Integer validityPeriod
) {}