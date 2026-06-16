package com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationTypeEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface SpecializationTypeMapper {

    SpecializationTypeDTO toDto(SpecializationTypeEntity entity);

    SpecializationTypeEntity toEntity(SpecializationTypeDTO dto);
}