package com.techhunter.tech_hunter_engine_api.mapper.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.JobCategoryDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.JobCategoryEntity;
import org.springframework.stereotype.Component;

@Component
public class JobCategoryMapper {

    public JobCategoryDTO toDTO(JobCategoryEntity e) {
        if (e == null) return null;

        return new JobCategoryDTO(
                e.getJobCategoryId(),
                e.getName(),
                e.getComplexityScore(),
                e.getCode(),
                e.getDescription()
        );
    }
}
