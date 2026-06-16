package com.techhunter.tech_hunter_engine_api.controller.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.SkillDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.SkillService;
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
class SkillControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SkillService skillService;

    @Test
    void getByTechnology_shouldReturnList() throws Exception {

        List<SkillDTO> skills = List.of(
                SkillDTO.builder()
                        .skillCode(1L)
                        .name("Java")
                        .rating(new BigDecimal("4.5"))
                        .description("Core Java")
                        .versionCode(17L)
                        .versionName("Java 17")
                        .technologyCode(10L)
                        .technologyName("Backend")
                        .build(),
                SkillDTO.builder()
                        .skillCode(2L)
                        .name("Spring Boot")
                        .rating(new BigDecimal("4.8"))
                        .description("Backend framework")
                        .versionCode(3L)
                        .versionName("Spring 3.2")
                        .technologyCode(10L)
                        .technologyName("Backend")
                        .build()
        );

        when(skillService.getByTechnology(10L)).thenReturn(skills);

        mockMvc.perform(get("/skills")
                        .param("technology", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].skillCode").value(1))
                .andExpect(jsonPath("$[0].name").value("Java"))
                .andExpect(jsonPath("$[0].rating").value(4.5))
                .andExpect(jsonPath("$[0].description").value("Core Java"))
                .andExpect(jsonPath("$[0].versionCode").value(17))
                .andExpect(jsonPath("$[0].versionName").value("Java 17"))
                .andExpect(jsonPath("$[0].technologyCode").value(10))
                .andExpect(jsonPath("$[0].technologyName").value("Backend"));
    }

    @Test
    void getByVersion_shouldReturnList() throws Exception {

        List<SkillDTO> skills = List.of(
                SkillDTO.builder()
                        .skillCode(3L)
                        .name("Docker")
                        .rating(new BigDecimal("4.2"))
                        .description("Containerization")
                        .versionCode(25L)
                        .versionName("Docker 25")
                        .technologyCode(20L)
                        .technologyName("DevOps")
                        .build()
        );

        when(skillService.getByVersion(5L)).thenReturn(skills);

        mockMvc.perform(get("/skills")
                        .param("version", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].skillCode").value(3))
                .andExpect(jsonPath("$[0].name").value("Docker"))
                .andExpect(jsonPath("$[0].rating").value(4.2))
                .andExpect(jsonPath("$[0].description").value("Containerization"))
                .andExpect(jsonPath("$[0].versionCode").value(25))
                .andExpect(jsonPath("$[0].versionName").value("Docker 25"))
                .andExpect(jsonPath("$[0].technologyCode").value(20))
                .andExpect(jsonPath("$[0].technologyName").value("DevOps"));
    }
}

