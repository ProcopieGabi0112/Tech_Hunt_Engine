package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.OrganizationTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.OrganizationTypeEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.OrganizationTypeRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.OrganizationTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationTypeServiceImpl implements OrganizationTypeService {

    private final OrganizationTypeRepository repository;

    @Override
    public List<OrganizationTypeDTO> getAllOrganizationTypes() {
        return repository.findAll().stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public OrganizationTypeDTO getOrganizationTypeById(Long id) {
        return repository.findById(id)
                .map(this::mapToDTO)
                .orElse(null);
    }

    private OrganizationTypeDTO mapToDTO(OrganizationTypeEntity e) {
        return new OrganizationTypeDTO(
                e.getCompanyTypeId(),
                e.getName(),
                e.getCode(),
                e.getDescription()
        );
    }
}
