package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyTypeDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.TechnologyTypeMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.TechnologyTypeEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.TechnologyTypeRepository;
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
class TechnologyTypeServiceImplTest {

    @Mock
    private TechnologyTypeRepository repository;

    @Mock
    private TechnologyTypeMapper mapper;

    @InjectMocks
    private TechnologyTypeServiceImpl service;

    // -----------------------------------------------------
    // GET ALL TYPES - normal flow
    // -----------------------------------------------------
    @Test
    void getAllTypes_shouldReturnMappedDTOs() {

        TechnologyTypeEntity entity = new TechnologyTypeEntity();
        entity.setTechnologyTypeCode(1L);

        TechnologyTypeDTO dto = TechnologyTypeDTO.builder()
                .technologyTypeCode(1L)
                .name("Backend")
                .rating(BigDecimal.valueOf(4.7))
                .description("Backend technologies")
                .build();

        when(repository.findAll())
                .thenReturn(List.of(entity));

        when(mapper.toDto(entity))
                .thenReturn(dto);

        List<TechnologyTypeDTO> result = service.getAllTypes();

        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).getTechnologyTypeCode());
        assertEquals("Backend", result.get(0).getName());
        assertEquals(BigDecimal.valueOf(4.7), result.get(0).getRating());
        assertEquals("Backend technologies", result.get(0).getDescription());
    }

    // -----------------------------------------------------
    // GET ALL TYPES - empty list
    // -----------------------------------------------------
    @Test
    void getAllTypes_shouldReturnEmptyList_whenNoTypes() {

        when(repository.findAll())
                .thenReturn(List.of());

        List<TechnologyTypeDTO> result = service.getAllTypes();

        assertTrue(result.isEmpty());
    }
}

