package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

public record DepartmentTypeDTO(
        Long departmentTypeId,
        String name,
        String code,
        String description
) {}
