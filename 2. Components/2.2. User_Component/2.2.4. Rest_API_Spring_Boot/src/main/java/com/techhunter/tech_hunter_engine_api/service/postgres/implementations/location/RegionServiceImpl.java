package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.RegionDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.RegionMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.RegionRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.RegionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RegionServiceImpl implements RegionService {

    private final RegionRepository regionRepository;
    private final RegionMapper regionMapper;

    @Override
    public List<RegionDTO> getAllRegions() {
        return regionRepository.findAll()
                .stream()
                .map(regionMapper::toDto)
                .toList();
    }
}