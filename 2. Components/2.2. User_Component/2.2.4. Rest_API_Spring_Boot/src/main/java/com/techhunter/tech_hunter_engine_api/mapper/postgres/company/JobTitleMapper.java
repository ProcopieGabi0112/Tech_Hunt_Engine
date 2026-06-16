package com.techhunter.tech_hunter_engine_api.mapper.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.JobTitleDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.JobTitleEntity;
import org.springframework.stereotype.Component;

@Component
public class JobTitleMapper {

    public JobTitleDTO toDTO(JobTitleEntity e) {
        if (e == null) return null;

        return new JobTitleDTO(
                e.getJobTitleId(),
                e.getName(),
                e.getComplexityScore(),
                e.getCode(),
                e.getDescription()
        );
    }
}
