package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.IndustryTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.IndustryTypeEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.IndustryTypeRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.IndustryTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class IndustryTypeServiceImpl implements IndustryTypeService {

    private final IndustryTypeRepository repository;

    @Override
    public List<IndustryTypeDTO> getAllIndustryTypes() {
        return repository.findAll().stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public IndustryTypeDTO getIndustryTypeById(Long id) {
        return repository.findById(id)
                .map(this::mapToDTO)
                .orElse(null);
    }

    private IndustryTypeDTO mapToDTO(IndustryTypeEntity e) {
        return new IndustryTypeDTO(
                e.getIndustryTypeId(),
                e.getName(),
                e.getCode(),
                e.getDescription()
        );
    }
}
