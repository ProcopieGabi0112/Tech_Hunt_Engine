package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.IndustryTypeDTO;

import java.util.List;

public interface IndustryTypeService {

    List<IndustryTypeDTO> getAllIndustryTypes();

    IndustryTypeDTO getIndustryTypeById(Long id);
}
