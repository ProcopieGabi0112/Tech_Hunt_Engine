package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.VersionDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.VersionMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.VersionEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.VersionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VersionServiceImplTest {

    @Mock
    private VersionRepository repository;

    @Mock
    private VersionMapper mapper;

    @InjectMocks
    private VersionServiceImpl service;

    // -----------------------------------------------------
    // GET BY TECHNOLOGY - normal flow
    // -----------------------------------------------------
    @Test
    void getByTechnology_shouldReturnMappedDTOs() {

        VersionEntity entity = new VersionEntity();
        entity.setVersionCode(10L);

        VersionDTO dto = new VersionDTO(
                10L,
                "Java 17",
                LocalDate.of(2021, 9, 14),
                LocalDate.of(2029, 9, 14),
                "Sealed classes, pattern matching",
                new BigDecimal("90.00"),
                new BigDecimal("85.00"),
                new BigDecimal("88.00"),
                new BigDecimal("92.00"),
                new BigDecimal("95.00"),
                new BigDecimal("93.00"),
                "LTS release",
                1L
        );

        when(repository.findByTechnology_TechnologyCode(1L))
                .thenReturn(List.of(entity));

        when(mapper.toDto(entity))
                .thenReturn(dto);

        List<VersionDTO> result = service.getByTechnology(1L);

        assertEquals(1, result.size());
        VersionDTO v = result.get(0);

        assertEquals(10L, v.getVersionCode());
        assertEquals("Java 17", v.getName());
        assertEquals(LocalDate.of(2021, 9, 14), v.getReleaseDate());
        assertEquals(LocalDate.of(2029, 9, 14), v.getEndOfLife());
        assertEquals("Sealed classes, pattern matching", v.getNewFeatures());
        assertEquals(new BigDecimal("90.00"), v.getDeveloperPopularity());
        assertEquals(new BigDecimal("85.00"), v.getCommunitySupport());
        assertEquals(new BigDecimal("88.00"), v.getIndustryUsageScore());
        assertEquals(new BigDecimal("92.00"), v.getKnowledgeScore());
        assertEquals(new BigDecimal("95.00"), v.getSkillsRating());
        assertEquals(new BigDecimal("93.00"), v.getRating());
        assertEquals("LTS release", v.getDescription());
        assertEquals(1L, v.getTechnologyCode());
    }

    // -----------------------------------------------------
    // GET BY TECHNOLOGY - empty list
    // -----------------------------------------------------
    @Test
    void getByTechnology_shouldReturnEmptyList_whenNoVersions() {

        when(repository.findByTechnology_TechnologyCode(1L))
                .thenReturn(List.of());

        List<VersionDTO> result = service.getByTechnology(1L);

        assertTrue(result.isEmpty());
    }
}


