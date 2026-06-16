package com.techhunter.tech_hunter_engine_api.dto.postgres.certification;

import java.math.BigDecimal;

public record LanguageDTO(
        Long langCode,
        String name,
        String isoCode,
        BigDecimal rating
) {}
