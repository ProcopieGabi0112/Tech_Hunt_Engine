package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LanguageDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LanguageEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.certification.LanguageRepository;
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
class LanguageServiceTest {

    @Mock
    private LanguageRepository languageRepository;

    @InjectMocks
    private LanguageService languageService;

    @Test
    void getAllLanguages_shouldReturnMappedDTOs() {

        LanguageEntity lang = new LanguageEntity();
        lang.setLangCode(1L);
        lang.setName("English");
        lang.setIsoCode("EN");
        lang.setRating(BigDecimal.valueOf(4.8));

        when(languageRepository.findAll())
                .thenReturn(List.of(lang));

        List<LanguageDTO> result = languageService.getAllLanguages();

        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).langCode());
        assertEquals("English", result.get(0).name());
        assertEquals("EN", result.get(0).isoCode());
        assertEquals(BigDecimal.valueOf(4.8), result.get(0).rating());
    }

    @Test
    void getAllLanguages_shouldReturnEmptyList_whenNoLanguages() {

        when(languageRepository.findAll())
                .thenReturn(List.of());

        List<LanguageDTO> result = languageService.getAllLanguages();

        assertTrue(result.isEmpty());
    }
}
