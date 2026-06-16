package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.AdministrativeUnitMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.AdministrativeUnitRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.AdministrativeUnitService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdministrativeUnitServiceImpl implements AdministrativeUnitService {

    private final AdministrativeUnitRepository administrativeUnitRepository;
    private final AdministrativeUnitMapper administrativeUnitMapper;

    @Override
    public List<AdministrativeUnitDTO> getUnitsByCountry(Long countryId) {
        return administrativeUnitRepository.findByCountry_CountryId(countryId)
                .stream()
                .map(administrativeUnitMapper::toDto)
                .toList();
    }
}