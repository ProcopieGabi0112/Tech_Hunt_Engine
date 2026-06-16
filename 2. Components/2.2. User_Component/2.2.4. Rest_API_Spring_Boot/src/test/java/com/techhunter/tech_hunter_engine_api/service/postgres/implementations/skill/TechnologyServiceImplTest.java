package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.TechnologyMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.TechnologyRepository;
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
class TechnologyServiceImplTest {

    @Mock
    private TechnologyRepository repository;

    @Mock
    private TechnologyMapper mapper;

    @InjectMocks
    private TechnologyServiceImpl service;

    // -----------------------------------------------------
    // GET BY TYPE - normal flow
    // -----------------------------------------------------
    @Test
    void getByType_shouldReturnMappedDTOs() {

        TechnologyEntity entity = new TechnologyEntity();
        entity.setTechnologyCode(10L);

        TechnologyDTO dto = new TechnologyDTO(
                10L,
                "Spring Boot",
                1L
        );

        when(repository.findByTechnologyType_TechnologyTypeCode(1L))
                .thenReturn(List.of(entity));

        when(mapper.toDto(entity))
                .thenReturn(dto);

        List<TechnologyDTO> result = service.getByType(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).getTechnologyCode());
        assertEquals("Spring Boot", result.get(0).getName());
        assertEquals(1L, result.get(0).getTechnologyTypeCode());
    }

    // -----------------------------------------------------
    // GET BY TYPE - empty list
    // -----------------------------------------------------
    @Test
    void getByType_shouldReturnEmptyList_whenNoTechnologies() {

        when(repository.findByTechnologyType_TechnologyTypeCode(1L))
                .thenReturn(List.of());

        List<TechnologyDTO> result = service.getByType(1L);

        assertTrue(result.isEmpty());
    }
}
