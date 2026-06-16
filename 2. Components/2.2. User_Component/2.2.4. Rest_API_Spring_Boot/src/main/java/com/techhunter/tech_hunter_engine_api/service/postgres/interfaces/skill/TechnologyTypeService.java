package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyTypeDTO;

import java.util.List;

public interface TechnologyTypeService {
    List<TechnologyTypeDTO> getAllTypes();
}
