package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization.SpecializationMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.SpecializationRepository;
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
class SpecializationServiceImplTest {

    @Mock
    private SpecializationRepository specializationRepository;

    @Mock
    private SpecializationMapper specializationMapper;

    @InjectMocks
    private SpecializationServiceImpl specializationService;

    // -----------------------------------------------------
    // GET BY INSTITUTION - normal flow
    // -----------------------------------------------------
    @Test
    void getSpecializationsByInstitution_shouldReturnMappedDTOs() {

        SpecializationEntity entity = new SpecializationEntity();
        entity.setSpecializationId(10L);

        SpecializationDTO dto = new SpecializationDTO(
                10L,
                "Computer Science",
                "Bachelor",
                95.0,
                4.7,
                4.6,
                3.8,
                4.0,
                4.9,
                4.8,
                "Top CS program",
                200L,
                5L
        );

        when(specializationRepository.findByInstitution_InstitutionId(200L))
                .thenReturn(List.of(entity));

        when(specializationMapper.toDto(entity))
                .thenReturn(dto);

        List<SpecializationDTO> result = specializationService.getSpecializationsByInstitution(200L);

        assertEquals(1, result.size());
        SpecializationDTO s = result.get(0);

        assertEquals(10L, s.specializationId());
        assertEquals("Computer Science", s.name());
        assertEquals("Bachelor", s.degreeType());
        assertEquals(95.0, s.employmentRate());
        assertEquals(4.7, s.teachersFeedback());
        assertEquals(4.6, s.coursesFeedback());
        assertEquals(3.8, s.entryDifficulty());
        assertEquals(4.0, s.graduationDifficulty());
        assertEquals(4.9, s.industryReputation());
        assertEquals(4.8, s.rating());
        assertEquals("Top CS program", s.description());
        assertEquals(200L, s.institutionId());
        assertEquals(5L, s.specializationTypeId());
    }

    // -----------------------------------------------------
    // GET BY INSTITUTION - empty list
    // -----------------------------------------------------
    @Test
    void getSpecializationsByInstitution_shouldReturnEmptyList_whenNoSpecializations() {

        when(specializationRepository.findByInstitution_InstitutionId(200L))
                .thenReturn(List.of());

        List<SpecializationDTO> result = specializationService.getSpecializationsByInstitution(200L);

        assertTrue(result.isEmpty());
    }
}

