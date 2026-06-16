package com.techhunter.tech_hunter_engine_api.controller.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LanguageDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification.LanguageService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
class LanguageControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LanguageService languageService;

    @Test
    void getLanguages_shouldReturnList() throws Exception {

        List<LanguageDTO> languages = List.of(
                new LanguageDTO(1L, "English", "EN", new BigDecimal("5.0")),
                new LanguageDTO(2L, "Romanian", "RO", new BigDecimal("4.5"))
        );

        when(languageService.getAllLanguages()).thenReturn(languages);

        mockMvc.perform(get("/languages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].langCode").value(1))
                .andExpect(jsonPath("$[0].name").value("English"))
                .andExpect(jsonPath("$[0].isoCode").value("EN"))
                .andExpect(jsonPath("$[0].rating").value(5.0))
                .andExpect(jsonPath("$[1].langCode").value(2))
                .andExpect(jsonPath("$[1].name").value("Romanian"))
                .andExpect(jsonPath("$[1].isoCode").value("RO"))
                .andExpect(jsonPath("$[1].rating").value(4.5));
    }
}

