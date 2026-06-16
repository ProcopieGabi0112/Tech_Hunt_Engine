package com.techhunter.tech_hunter_engine_api.controller.certification;

import com.techhunter.tech_hunter_engine_api.controller.postgres.certification.LangLevelController;
import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LangLevelDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification.LangLevelService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.SecurityFilterAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
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
class LangLevelControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LangLevelService langLevelService;

    @Test
    void getLevelsByLanguage_shouldReturnList() throws Exception {

        List<LangLevelDTO> levels = List.of(
                new LangLevelDTO(
                        1L,
                        "A1",
                        "Beginner",
                        new BigDecimal("1.0"),
                        24
                ),
                new LangLevelDTO(
                        2L,
                        "A2",
                        "Elementary",
                        new BigDecimal("2.0"),
                        24
                )
        );

        when(langLevelService.getLevelsByLanguage(1L)).thenReturn(levels);

        mockMvc.perform(get("/lang-levels")
                        .param("langCode", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].langLevelId").value(1))
                .andExpect(jsonPath("$[0].name").value("A1"))
                .andExpect(jsonPath("$[0].nivel").value("Beginner"))
                .andExpect(jsonPath("$[0].rating").value(1.0))
                .andExpect(jsonPath("$[0].validityPeriod").value(24));
    }
}
