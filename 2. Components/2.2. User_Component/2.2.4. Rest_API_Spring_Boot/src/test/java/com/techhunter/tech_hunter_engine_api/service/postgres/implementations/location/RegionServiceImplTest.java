package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.RegionDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.location.RegionMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.RegionEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.location.RegionRepository;
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
class RegionServiceImplTest {

    @Mock
    private RegionRepository regionRepository;

    @Mock
    private RegionMapper regionMapper;

    @InjectMocks
    private RegionServiceImpl regionService;

    // -----------------------------------------------------
    // GET ALL REGIONS - normal flow
    // -----------------------------------------------------
    @Test
    void getAllRegions_shouldReturnMappedDTOs() {

        RegionEntity entity = new RegionEntity();
        entity.setRegionId(1L);

        RegionDTO dto = new RegionDTO(
                1L,
                "Europe",
                "EU",
                "European region"
        );

        when(regionRepository.findAll())
                .thenReturn(List.of(entity));

        when(regionMapper.toDto(entity))
                .thenReturn(dto);

        List<RegionDTO> result = regionService.getAllRegions();

        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).regionId());
        assertEquals("Europe", result.get(0).name());
        assertEquals("EU", result.get(0).code());
        assertEquals("European region", result.get(0).description());
    }

    // -----------------------------------------------------
    // GET ALL REGIONS - empty list
    // -----------------------------------------------------
    @Test
    void getAllRegions_shouldReturnEmptyList_whenNoRegions() {

        when(regionRepository.findAll())
                .thenReturn(List.of());

        List<RegionDTO> result = regionService.getAllRegions();

        assertTrue(result.isEmpty());
    }
}
