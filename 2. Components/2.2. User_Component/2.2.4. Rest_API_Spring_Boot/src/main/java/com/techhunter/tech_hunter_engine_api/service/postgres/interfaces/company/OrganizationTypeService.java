package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.OrganizationTypeDTO;

import java.util.List;

public interface OrganizationTypeService {

    List<OrganizationTypeDTO> getAllOrganizationTypes();

    OrganizationTypeDTO getOrganizationTypeById(Long id);
}
