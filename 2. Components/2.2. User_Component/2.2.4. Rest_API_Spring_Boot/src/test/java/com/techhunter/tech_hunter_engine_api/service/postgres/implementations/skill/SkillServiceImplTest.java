package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.SkillDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.SkillMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.SkillEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.SkillRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SkillServiceImplTest {

    @Mock
    private SkillRepository repository;

    @Mock
    private SkillMapper mapper;

    @InjectMocks
    private SkillServiceImpl service;

    @Test
    void getByTechnology_shouldReturnMappedDTOs() {

        SkillEntity entity = new SkillEntity();
        entity.setSkillCode(10L);

        SkillDTO dto = SkillDTO.builder()
                .skillCode(10L)
                .name("Spring Boot")
                .rating(BigDecimal.valueOf(4.8))
                .description("Backend framework")
                .versionCode(200L)
                .versionName("3.2")
                .technologyCode(1L)
                .technologyName("Java")
                .build();

        when(repository.findByLastVersion_Technology_TechnologyCode(1L))
                .thenReturn(List.of(entity));

        when(mapper.toDto(entity))
                .thenReturn(dto);

        List<SkillDTO> result = service.getByTechnology(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).getSkillCode());
        assertEquals("Spring Boot", result.get(0).getName());
        assertEquals(BigDecimal.valueOf(4.8), result.get(0).getRating());
        assertEquals("Backend framework", result.get(0).getDescription());
        assertEquals(200L, result.get(0).getVersionCode());
        assertEquals("3.2", result.get(0).getVersionName());
        assertEquals(1L, result.get(0).getTechnologyCode());
        assertEquals("Java", result.get(0).getTechnologyName());
    }
}