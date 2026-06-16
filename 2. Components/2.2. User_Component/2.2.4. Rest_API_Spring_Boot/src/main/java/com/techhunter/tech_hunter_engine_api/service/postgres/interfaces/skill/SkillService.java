package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.SkillDTO;

import java.util.List;

public interface SkillService {
    List<SkillDTO> getByTechnology(Long technologyCode);
    List<SkillDTO> getByVersion(Long versionCode);
}