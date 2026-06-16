package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.LocationDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.LocationMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.LocationRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.LocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LocationServiceImpl implements LocationService {

    private final LocationRepository locationRepository;
    private final LocationMapper locationMapper;

    @Override
    public List<LocationDTO> getLocationsByCity(Long cityCode) {
        return locationRepository.findByCity_CityCode(cityCode)
                .stream()
                .map(locationMapper::toDto)
                .toList();
    }
}