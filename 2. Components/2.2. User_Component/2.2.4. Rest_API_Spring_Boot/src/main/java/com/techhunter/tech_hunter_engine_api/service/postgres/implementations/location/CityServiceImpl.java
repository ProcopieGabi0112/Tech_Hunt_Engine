package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CityDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.CityMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.CityRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.CityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CityServiceImpl implements CityService {

    private final CityRepository cityRepository;
    private final CityMapper cityMapper;

    @Override
    public List<CityDTO> getCitiesByAdministrativeUnit(Long administrativeUnitId) {
        return cityRepository.findByAdministrativeUnit_AdministrativeUnitId(administrativeUnitId)
                .stream()
                .map(cityMapper::toDto)
                .toList();
    }
}