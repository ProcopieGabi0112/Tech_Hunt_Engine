package com.techhunter.tech_hunter_engine_api.dto.postgres.specialization;

public record SpecializationDTO(
        Long specializationId,
        String name,
        String degreeType,
        Double employmentRate,
        Double teachersFeedback,
        Double coursesFeedback,
        Double entryDifficulty,
        Double graduationDifficulty,
        Double industryReputation,
        Double rating,
        String description,
        Long institutionId,
        Long specializationTypeId
) {}
