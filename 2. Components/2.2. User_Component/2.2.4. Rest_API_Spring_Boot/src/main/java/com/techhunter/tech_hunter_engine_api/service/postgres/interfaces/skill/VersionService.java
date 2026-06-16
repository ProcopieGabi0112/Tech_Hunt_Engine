package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.VersionDTO;

import java.util.List;

public interface VersionService {
    List<VersionDTO> getByTechnology(Long technologyCode);
}
