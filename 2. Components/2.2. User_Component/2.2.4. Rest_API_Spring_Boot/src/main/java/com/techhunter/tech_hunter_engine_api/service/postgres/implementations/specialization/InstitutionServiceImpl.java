package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.InstitutionDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization.InstitutionMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.InstitutionRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization.InstitutionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InstitutionServiceImpl implements InstitutionService {

    private final InstitutionRepository institutionRepository;
    private final InstitutionMapper institutionMapper;

    @Override
    public List<InstitutionDTO> getInstitutionsByLocation(Long locationId) {
        return institutionRepository.findByLocation_LocationId(locationId)
                .stream()
                .map(institutionMapper::toDto)
                .toList();
    }
}