package com.techhunter.tech_hunter_engine_api.mapper.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.JobLevelDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.JobLevelEntity;
import org.springframework.stereotype.Component;

@Component
public class JobLevelMapper {

    public JobLevelDTO toDTO(JobLevelEntity e) {
        if (e == null) return null;

        return new JobLevelDTO(
                e.getJobLevelId(),
                e.getName(),
                e.getComplexityScore(),
                e.getCode(),
                e.getDescription()
        );
    }
}
