package com.techhunter.tech_hunter_engine_api.dto.postgres.specialization;

public record SpecializationTypeDTO(
        Long specializationTypeId,
        String name,
        String description
) {}
