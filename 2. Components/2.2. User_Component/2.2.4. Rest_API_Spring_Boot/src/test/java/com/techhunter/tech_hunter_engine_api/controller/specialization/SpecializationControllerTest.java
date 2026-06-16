package com.techhunter.tech_hunter_engine_api.controller.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization.SpecializationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@TestPropertySource(properties = {
        "app.default-users.enabled=false",
        "spring.datasource.url=jdbc:h2:mem:testdb",
        "spring.datasource.driverClassName=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.database-platform=org.hibernate.dialect.H2Dialect",
        "spring.jpa.hibernate.ddl-auto=none",
        "spring.jpa.show-sql=false"
})
class SpecializationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SpecializationService specializationService;

    @Test
    void getSpecializationsByInstitution_shouldReturnList() throws Exception {

        List<SpecializationDTO> specs = List.of(
                new SpecializationDTO(
                        1L,
                        "Computer Science",
                        "Bachelor",
                        92.5,
                        4.7,
                        4.8,
                        3.9,
                        4.2,
                        4.6,
                        4.75,
                        "Top CS program",
                        10L,
                        100L
                ),
                new SpecializationDTO(
                        2L,
                        "Software Engineering",
                        "Master",
                        89.3,
                        4.6,
                        4.7,
                        4.1,
                        4.3,
                        4.5,
                        4.65,
                        "Advanced SE program",
                        10L,
                        100L
                )
        );

        when(specializationService.getSpecializationsByInstitution(10L)).thenReturn(specs);

        mockMvc.perform(get("/specializations")
                        .param("institutionId", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].specializationId").value(1))
                .andExpect(jsonPath("$[0].name").value("Computer Science"))
                .andExpect(jsonPath("$[0].degreeType").value("Bachelor"))
                .andExpect(jsonPath("$[0].employmentRate").value(92.5))
                .andExpect(jsonPath("$[0].teachersFeedback").value(4.7))
                .andExpect(jsonPath("$[0].coursesFeedback").value(4.8))
                .andExpect(jsonPath("$[0].entryDifficulty").value(3.9))
                .andExpect(jsonPath("$[0].graduationDifficulty").value(4.2))
                .andExpect(jsonPath("$[0].industryReputation").value(4.6))
                .andExpect(jsonPath("$[0].rating").value(4.75))
                .andExpect(jsonPath("$[0].description").value("Top CS program"))
                .andExpect(jsonPath("$[0].institutionId").value(10))
                .andExpect(jsonPath("$[0].specializationTypeId").value(100))
                .andExpect(jsonPath("$[1].specializationId").value(2))
                .andExpect(jsonPath("$[1].name").value("Software Engineering"))
                .andExpect(jsonPath("$[1].degreeType").value("Master"))
                .andExpect(jsonPath("$[1].employmentRate").value(89.3))
                .andExpect(jsonPath("$[1].teachersFeedback").value(4.6))
                .andExpect(jsonPath("$[1].coursesFeedback").value(4.7))
                .andExpect(jsonPath("$[1].entryDifficulty").value(4.1))
                .andExpect(jsonPath("$[1].graduationDifficulty").value(4.3))
                .andExpect(jsonPath("$[1].industryReputation").value(4.5))
                .andExpect(jsonPath("$[1].rating").value(4.65))
                .andExpect(jsonPath("$[1].description").value("Advanced SE program"))
                .andExpect(jsonPath("$[1].institutionId").value(10))
                .andExpect(jsonPath("$[1].specializationTypeId").value(100));
    }
}

