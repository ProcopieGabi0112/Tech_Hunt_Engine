package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.AdministrativeUnitMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.AdministrativeUnitRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AdministrativeUnitServiceImplTest {

    @Mock
    private AdministrativeUnitRepository administrativeUnitRepository;

    @Mock
    private AdministrativeUnitMapper administrativeUnitMapper;

    @InjectMocks
    private AdministrativeUnitServiceImpl administrativeUnitService;

    // -----------------------------------------------------
    // GET UNITS BY COUNTRY - normal flow
    // -----------------------------------------------------
    @Test
    void getUnitsByCountry_shouldReturnMappedDTOs() {

        AdministrativeUnitEntity entity = new AdministrativeUnitEntity();
        entity.setAdministrativeUnitId(100L);

        AdministrativeUnitDTO dto = new AdministrativeUnitDTO(
                100L,
                "London Borough",
                "LND01",
                900000L,
                157L,
                32L,
                "Capital administrative unit",
                5L,
                "Metropolitan Borough",
                44L
        );

        when(administrativeUnitRepository.findByCountry_CountryId(44L))
                .thenReturn(List.of(entity));

        when(administrativeUnitMapper.toDto(entity))
                .thenReturn(dto);

        List<AdministrativeUnitDTO> result = administrativeUnitService.getUnitsByCountry(44L);

        assertEquals(1, result.size());
        assertEquals(100L, result.get(0).administrativeUnitId());
        assertEquals("London Borough", result.get(0).name());
        assertEquals("LND01", result.get(0).code());
        assertEquals(900000L, result.get(0).population());
        assertEquals(157L, result.get(0).area());
        assertEquals(32L, result.get(0).numberOfCities());
        assertEquals("Capital administrative unit", result.get(0).description());
        assertEquals(5L, result.get(0).administrativeUnitTypeId());
        assertEquals("Metropolitan Borough", result.get(0).administrativeUnitTypeName());
        assertEquals(44L, result.get(0).countryId());
    }

    // -----------------------------------------------------
    // GET UNITS BY COUNTRY - empty list
    // -----------------------------------------------------
    @Test
    void getUnitsByCountry_shouldReturnEmptyList_whenNoUnits() {

        when(administrativeUnitRepository.findByCountry_CountryId(44L))
                .thenReturn(List.of());

        List<AdministrativeUnitDTO> result = administrativeUnitService.getUnitsByCountry(44L);

        assertTrue(result.isEmpty());
    }
}
