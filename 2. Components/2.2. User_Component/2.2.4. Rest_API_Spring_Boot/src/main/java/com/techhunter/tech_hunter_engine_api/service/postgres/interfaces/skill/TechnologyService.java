package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyDTO;

import java.util.List;

public interface TechnologyService {
    List<TechnologyDTO> getByType(Long typeCode);
}