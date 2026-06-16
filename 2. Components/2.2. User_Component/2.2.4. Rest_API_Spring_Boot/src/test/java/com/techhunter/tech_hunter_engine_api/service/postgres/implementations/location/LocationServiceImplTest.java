package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.LocationDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.LocationMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.LocationEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.LocationRepository;
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
class LocationServiceImplTest {

    @Mock
    private LocationRepository locationRepository;

    @Mock
    private LocationMapper locationMapper;

    @InjectMocks
    private LocationServiceImpl locationService;

    // -----------------------------------------------------
    // GET LOCATIONS BY CITY - normal flow
    // -----------------------------------------------------
    @Test
    void getLocationsByCity_shouldReturnMappedDTOs() {

        LocationEntity entity = new LocationEntity();
        entity.setLocationId(10L);

        LocationDTO dto = new LocationDTO(
                10L,
                "Main Street",
                "12A",
                "12345",
                "B1",
                "S2",
                "3",
                "10",
                200L
        );

        when(locationRepository.findByCity_CityCode(200L))
                .thenReturn(List.of(entity));

        when(locationMapper.toDto(entity))
                .thenReturn(dto);

        List<LocationDTO> result = locationService.getLocationsByCity(200L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).locationId());
        assertEquals("Main Street", result.get(0).streetName());
        assertEquals("12A", result.get(0).streetNumber());
        assertEquals("12345", result.get(0).postalCode());
        assertEquals("B1", result.get(0).building());
        assertEquals("S2", result.get(0).staircase());
        assertEquals("3", result.get(0).floor());
        assertEquals("10", result.get(0).apartmentNumber());
        assertEquals(200L, result.get(0).cityCode());
    }

    // -----------------------------------------------------
    // GET LOCATIONS BY CITY - empty list
    // -----------------------------------------------------
    @Test
    void getLocationsByCity_shouldReturnEmptyList_whenNoLocations() {

        when(locationRepository.findByCity_CityCode(200L))
                .thenReturn(List.of());

        List<LocationDTO> result = locationService.getLocationsByCity(200L);

        assertTrue(result.isEmpty());
    }
}
