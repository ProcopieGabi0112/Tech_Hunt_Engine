package com.techhunter.tech_hunter_engine_api.mapper.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.WorkTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.WorkTypeEntity;
import org.springframework.stereotype.Component;

@Component
public class WorkTypeMapper {

    public WorkTypeDTO toDTO(WorkTypeEntity e) {
        if (e == null) return null;

        return new WorkTypeDTO(
                e.getWorkTypeId(),
                e.getName(),
                e.getComplexityScore(),
                e.getCode(),
                e.getDescription()
        );
    }
}
