package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CityDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.CityMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.CityEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.CityRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CityServiceImplTest {

    @Mock
    private CityRepository cityRepository;

    @Mock
    private CityMapper cityMapper;

    @InjectMocks
    private CityServiceImpl cityService;

    // -----------------------------------------------------
    // GET CITIES BY ADMIN UNIT - normal flow
    // -----------------------------------------------------
    @Test
    void getCitiesByAdministrativeUnit_shouldReturnMappedDTOs() {

        CityEntity city = new CityEntity();
        city.setCityCode(10L);

        CityDTO dto = new CityDTO(
                10L,
                "London",
                9000000L,
                157L,
                "N",
                51.5074,
                -0.1278,
                "Capital city",
                100L
        );

        when(cityRepository.findByAdministrativeUnit_AdministrativeUnitId(100L))
                .thenReturn(List.of(city));

        when(cityMapper.toDto(city))
                .thenReturn(dto);

        List<CityDTO> result = cityService.getCitiesByAdministrativeUnit(100L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).cityCode());
        assertEquals("London", result.get(0).name());
        assertEquals(9000000L, result.get(0).population());
        assertEquals(157L, result.get(0).area());
        assertEquals("N", result.get(0).isCapital());
        assertEquals(51.5074, result.get(0).latitude());
        assertEquals(-0.1278, result.get(0).longitude());
        assertEquals("Capital city", result.get(0).description());
        assertEquals(100L, result.get(0).administrativeUnitId());
    }

    // -----------------------------------------------------
    // GET CITIES BY ADMIN UNIT - empty list
    // -----------------------------------------------------
    @Test
    void getCitiesByAdministrativeUnit_shouldReturnEmptyList_whenNoCities() {

        when(cityRepository.findByAdministrativeUnit_AdministrativeUnitId(100L))
                .thenReturn(List.of());

        List<CityDTO> result = cityService.getCitiesByAdministrativeUnit(100L);

        assertTrue(result.isEmpty());
    }
}