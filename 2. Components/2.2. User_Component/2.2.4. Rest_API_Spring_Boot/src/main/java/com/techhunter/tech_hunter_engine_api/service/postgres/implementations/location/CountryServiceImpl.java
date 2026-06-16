package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CountryDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.CountryMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.CountryRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.CountryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CountryServiceImpl implements CountryService {

    private final CountryRepository countryRepository;
    private final CountryMapper countryMapper;

    @Override
    public List<CountryDTO> getCountriesByRegion(Long regionId) {
        return countryRepository.findByRegion_RegionId(regionId)
                .stream()
                .map(countryMapper::toDto)
                .toList();
    }
}