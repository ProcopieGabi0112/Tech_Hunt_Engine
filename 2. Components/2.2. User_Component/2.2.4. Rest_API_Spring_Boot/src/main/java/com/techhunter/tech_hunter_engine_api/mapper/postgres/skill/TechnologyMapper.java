package com.techhunter.tech_hunter_engine_api.mapper.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyTypeEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TechnologyMapper {

    @Mapping(source = "technologyType.technologyTypeCode", target = "technologyTypeCode")
    TechnologyDTO toDto(TechnologyEntity entity);

    @Mapping(target = "technologyType", expression = "java(createTechnologyTypeEntity(dto.getTechnologyTypeCode()))")
    TechnologyEntity toEntity(TechnologyDTO dto);

    default TechnologyTypeEntity createTechnologyTypeEntity(Long code) {
        if (code == null) return null;
        TechnologyTypeEntity t = new TechnologyTypeEntity();
        t.setTechnologyTypeCode(code);
        return t;
    }
}
