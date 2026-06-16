package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

import java.util.List;

public record JobMetadataResponseDTO(
        List<DepartmentTypeDTO> departmentTypes,
        List<EmploymentTypeDTO> employmentTypes,
        List<WorkTypeDTO> workTypes,
        List<JobCategoryDTO> jobCategories,
        List<JobTitleDTO> jobTitles,
        List<JobLevelDTO> jobLevels
) {}
