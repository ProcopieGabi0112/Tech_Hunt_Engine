package com.techhunter.tech_hunter_engine_api.mapper.postgres.skill;


import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyTypeEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface TechnologyTypeMapper {
    TechnologyTypeDTO toDto(TechnologyTypeEntity entity);
    TechnologyTypeEntity toEntity(TechnologyTypeDTO dto);
}
