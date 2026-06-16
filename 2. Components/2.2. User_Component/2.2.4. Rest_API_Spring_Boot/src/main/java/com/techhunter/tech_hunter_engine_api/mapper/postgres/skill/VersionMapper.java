package com.techhunter.tech_hunter_engine_api.mapper.postgres.skill;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.VersionDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.VersionEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyEntity;

@Mapper(componentModel = "spring")
public interface VersionMapper {

    @Mapping(source = "technology.technologyCode", target = "technologyCode")
    VersionDTO toDto(VersionEntity entity);

    @Mapping(target = "technology", expression = "java(createTechnologyEntity(dto.getTechnologyCode()))")
    VersionEntity toEntity(VersionDTO dto);

    // helper folosit de MapStruct pentru DTO -> Entity
    default TechnologyEntity createTechnologyEntity(Long technologyCode) {
        if (technologyCode == null) {
            return null;
        }
        TechnologyEntity t = new TechnologyEntity();
        t.setTechnologyCode(technologyCode);
        return t;
    }
}