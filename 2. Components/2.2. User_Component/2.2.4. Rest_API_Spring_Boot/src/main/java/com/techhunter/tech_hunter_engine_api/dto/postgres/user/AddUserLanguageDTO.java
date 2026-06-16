package com.techhunter.tech_hunter_engine_api.dto.postgres.user;

import java.time.LocalDate;

public record AddUserLanguageDTO(
        Long langLevelId,
        LocalDate obtainedDate
) {}
