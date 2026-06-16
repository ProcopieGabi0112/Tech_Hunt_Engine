package com.techhunter.tech_hunter_engine_api.mapper.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.SkillDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.SkillEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface SkillMapper {

    @Mapping(source = "lastVersion.versionCode", target = "versionCode")
    @Mapping(source = "lastVersion.name", target = "versionName")
    @Mapping(source = "lastVersion.technology.technologyCode", target = "technologyCode")
    @Mapping(source = "lastVersion.technology.name", target = "technologyName")
    SkillDTO toDto(SkillEntity entity);

    @Mapping(source = "versionCode", target = "lastVersion.versionCode")
    SkillEntity toEntity(SkillDTO dto);
}