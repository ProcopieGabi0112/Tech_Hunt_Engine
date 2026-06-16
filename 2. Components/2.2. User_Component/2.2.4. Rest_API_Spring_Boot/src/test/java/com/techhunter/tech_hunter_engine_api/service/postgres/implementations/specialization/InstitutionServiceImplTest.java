package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.InstitutionDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization.InstitutionMapper;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization.SpecializationMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.InstitutionEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.InstitutionRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.SpecializationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class InstitutionServiceImplTest {

    @Mock
    private InstitutionRepository institutionRepository;

    @Mock
    private InstitutionMapper institutionMapper;

    @InjectMocks
    private InstitutionServiceImpl institutionService;

    // -----------------------------------------------------
    // GET BY LOCATION - normal flow
    // -----------------------------------------------------
    @Test
    void getInstitutionsByLocation_shouldReturnMappedDTOs() {

        InstitutionEntity entity = new InstitutionEntity();
        entity.setInstitutionId(10L);

        InstitutionDTO dto = new InstitutionDTO(
                10L,
                "Politehnica University",
                "www.upb.ro",
                "1960",
                4.7,
                "Top engineering university",
                200L
        );

        when(institutionRepository.findByLocation_LocationId(200L))
                .thenReturn(List.of(entity));

        when(institutionMapper.toDto(entity))
                .thenReturn(dto);

        List<InstitutionDTO> result = institutionService.getInstitutionsByLocation(200L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).institutionId());
        assertEquals("Politehnica University", result.get(0).name());
        assertEquals("www.upb.ro", result.get(0).website());
        assertEquals("1960", result.get(0).foundingYear());
        assertEquals(4.7, result.get(0).rating());
        assertEquals("Top engineering university", result.get(0).description());
        assertEquals(200L, result.get(0).locationId());
    }

    // -----------------------------------------------------
    // GET BY LOCATION - empty list
    // -----------------------------------------------------
    @Test
    void getInstitutionsByLocation_shouldReturnEmptyList_whenNoInstitutions() {

        when(institutionRepository.findByLocation_LocationId(200L))
                .thenReturn(List.of());

        List<InstitutionDTO> result = institutionService.getInstitutionsByLocation(200L);

        assertTrue(result.isEmpty());
    }
}
