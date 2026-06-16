package com.techhunter.tech_hunter_engine_api.mapper.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UserSkillResponseDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.UserSkillEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserSkillMapper {

    @Mapping(source = "skill.skillCode", target = "skillCode")
    @Mapping(source = "skill.name", target = "skillName")
    @Mapping(source = "skill.lastVersion.name", target = "versionName")
    @Mapping(source = "skill.lastVersion.technology.name", target = "technologyName")
    @Mapping(source = "skill.lastVersion.technology.technologyType.name", target = "technologyTypeName")
    @Mapping(source = "proficiencyLevel", target = "proficiencyLevel")
    @Mapping(source = "experienceMonths", target = "experienceMonths")
    @Mapping(source = "lastUsedDate", target = "lastUsedDate")
    @Mapping(source = "confidenceScore", target = "confidenceScore")
    UserSkillResponseDTO toDto(UserSkillEntity entity);
}
