package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LangLevelDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LangLevelEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.certification.LangLevelRepository;
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
class LangLevelServiceTest {

    @Mock
    private LangLevelRepository langLevelRepository;

    @InjectMocks
    private LangLevelService langLevelService;

    // -----------------------------------------------------
    // GET LEVELS BY LANGUAGE - normal flow
    // -----------------------------------------------------
    @Test
    void getLevelsByLanguage_shouldReturnMappedDTOs() {

        LangLevelEntity level = new LangLevelEntity();
        level.setLangLevelId(10L);
        level.setName("B2");
        level.setNivel("Intermediate");
        level.setRating(BigDecimal.valueOf(4.5));
        level.setValidityPeriod(24);

        when(langLevelRepository.findByLanguage_LangCode(1L))
                .thenReturn(List.of(level));

        List<LangLevelDTO> result = langLevelService.getLevelsByLanguage(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).langLevelId());
        assertEquals("B2", result.get(0).name());
        assertEquals("Intermediate", result.get(0).nivel());
        assertEquals(BigDecimal.valueOf(4.5), result.get(0).rating());
        assertEquals(24, result.get(0).validityPeriod());
    }

    // -----------------------------------------------------
    // GET LEVELS BY LANGUAGE - empty list
    // -----------------------------------------------------
    @Test
    void getLevelsByLanguage_shouldReturnEmptyList_whenNoLevels() {

        when(langLevelRepository.findByLanguage_LangCode(1L))
                .thenReturn(List.of());

        List<LangLevelDTO> result = langLevelService.getLevelsByLanguage(1L);

        assertTrue(result.isEmpty());
    }
}
