package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization.SpecializationMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.SpecializationRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization.SpecializationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SpecializationServiceImpl implements SpecializationService {

    private final SpecializationRepository specializationRepository;
    private final SpecializationMapper specializationMapper;

    @Override
    public List<SpecializationDTO> getSpecializationsByInstitution(Long institutionId) {
        return specializationRepository.findByInstitution_InstitutionId(institutionId)
                .stream()
                .map(specializationMapper::toDto)
                .toList();
    }
}