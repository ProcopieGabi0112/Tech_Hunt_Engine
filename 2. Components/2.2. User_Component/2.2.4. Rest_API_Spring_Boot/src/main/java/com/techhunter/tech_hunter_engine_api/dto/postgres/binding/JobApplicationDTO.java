package com.techhunter.tech_hunter_engine_api.dto.postgres.binding;

import java.time.LocalDate;

public record JobApplicationDTO(
        Long applicationId,
        Long userId,
        Long jobId,
        String status,
        LocalDate applyDate,
        String salary,
        String applySource
) {}
