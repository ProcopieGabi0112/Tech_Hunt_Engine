package com.techhunter.tech_hunter_engine_api.mapper.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.DepartmentTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.DepartmentTypeEntity;
import org.springframework.stereotype.Component;

@Component
public class DepartmentTypeMapper {

    public DepartmentTypeDTO toDTO(DepartmentTypeEntity e) {
        if (e == null) return null;

        return new DepartmentTypeDTO(
                e.getDepartmentTypeId(),
                e.getName(),
                e.getCode(),
                e.getDescription()
        );
    }
}
