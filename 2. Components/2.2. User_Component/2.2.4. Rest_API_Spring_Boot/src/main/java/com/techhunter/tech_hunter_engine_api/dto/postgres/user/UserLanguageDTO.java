package com.techhunter.tech_hunter_engine_api.dto.postgres.user;

import java.math.BigDecimal;
import java.time.LocalDate;

public record UserLanguageDTO(
        Long langLevelId,
        String languageName,
        String isoCode,
        String certificationName,
        String nivel,
        BigDecimal ratingLanguage,
        BigDecimal ratingCertification,
        Integer validityPeriod,
        LocalDate obtainedDate
) {}
