package com.techhunter.tech_hunter_engine_api.mapper.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.EmploymentTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.EmploymentTypeEntity;
import org.springframework.stereotype.Component;

@Component
public class EmploymentTypeMapper {

    public EmploymentTypeDTO toDTO(EmploymentTypeEntity e) {
        if (e == null) return null;

        return new EmploymentTypeDTO(
                e.getEmploymentTypeId(),
                e.getName(),
                e.getComplexityScore(),
                e.getCode(),
                e.getDescription()
        );
    }
}
