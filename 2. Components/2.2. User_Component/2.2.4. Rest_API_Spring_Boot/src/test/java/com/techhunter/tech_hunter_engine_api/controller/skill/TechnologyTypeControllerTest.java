package com.techhunter.tech_hunter_engine_api.controller.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyTypeDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.TechnologyTypeService;
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
class TechnologyTypeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TechnologyTypeService technologyTypeService;

    @Test
    void getAllTypes_shouldReturnList() throws Exception {

        List<TechnologyTypeDTO> types = List.of(
                TechnologyTypeDTO.builder()
                        .technologyTypeCode(1L)
                        .name("Programming Language")
                        .rating(new BigDecimal("4.8"))
                        .description("Languages used for software development")
                        .build(),
                TechnologyTypeDTO.builder()
                        .technologyTypeCode(2L)
                        .name("Framework")
                        .rating(new BigDecimal("4.6"))
                        .description("Tools used to build applications")
                        .build()
        );

        when(technologyTypeService.getAllTypes()).thenReturn(types);

        mockMvc.perform(get("/technology-types"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].technologyTypeCode").value(1))
                .andExpect(jsonPath("$[0].name").value("Programming Language"))
                .andExpect(jsonPath("$[0].rating").value(4.8))
                .andExpect(jsonPath("$[0].description").value("Languages used for software development"))
                .andExpect(jsonPath("$[1].technologyTypeCode").value(2))
                .andExpect(jsonPath("$[1].name").value("Framework"))
                .andExpect(jsonPath("$[1].rating").value(4.6))
                .andExpect(jsonPath("$[1].description").value("Tools used to build applications"));
    }
}

