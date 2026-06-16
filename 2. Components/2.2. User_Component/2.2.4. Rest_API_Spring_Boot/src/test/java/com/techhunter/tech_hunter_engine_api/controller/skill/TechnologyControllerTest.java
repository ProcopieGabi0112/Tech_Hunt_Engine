package com.techhunter.tech_hunter_engine_api.controller.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.TechnologyService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
class TechnologyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TechnologyService technologyService;

    @Test
    void getByType_shouldReturnList() throws Exception {

        List<TechnologyDTO> technologies = List.of(
                new TechnologyDTO(
                        1L,
                        "Java",
                        100L
                ),
                new TechnologyDTO(
                        2L,
                        "Spring Boot",
                        100L
                )
        );

        when(technologyService.getByType(100L)).thenReturn(technologies);

        mockMvc.perform(get("/technologies")
                        .param("type", "100"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].technologyCode").value(1))
                .andExpect(jsonPath("$[0].name").value("Java"))
                .andExpect(jsonPath("$[0].technologyTypeCode").value(100))
                .andExpect(jsonPath("$[1].technologyCode").value(2))
                .andExpect(jsonPath("$[1].name").value("Spring Boot"))
                .andExpect(jsonPath("$[1].technologyTypeCode").value(100));
    }
}


