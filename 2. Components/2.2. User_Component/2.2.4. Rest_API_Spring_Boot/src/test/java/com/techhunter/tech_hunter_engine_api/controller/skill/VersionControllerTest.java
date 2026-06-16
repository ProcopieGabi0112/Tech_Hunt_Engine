package com.techhunter.tech_hunter_engine_api.controller.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.VersionDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.VersionService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
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
class VersionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private VersionService versionService;

    @Test
    void getByTechnology_shouldReturnList() throws Exception {

        List<VersionDTO> versions = List.of(
                new VersionDTO(
                        1L,
                        "Java 17",
                        LocalDate.of(2021, 9, 14),
                        LocalDate.of(2029, 9, 14),
                        "Sealed classes, pattern matching",
                        new BigDecimal("4.8"),
                        new BigDecimal("4.9"),
                        new BigDecimal("4.7"),
                        new BigDecimal("4.6"),
                        new BigDecimal("4.8"),
                        new BigDecimal("4.85"),
                        "LTS release",
                        10L
                ),
                new VersionDTO(
                        2L,
                        "Java 21",
                        LocalDate.of(2023, 9, 19),
                        LocalDate.of(2031, 9, 19),
                        "Virtual threads, pattern matching improvements",
                        new BigDecimal("4.9"),
                        new BigDecimal("4.9"),
                        new BigDecimal("4.8"),
                        new BigDecimal("4.7"),
                        new BigDecimal("4.9"),
                        new BigDecimal("4.90"),
                        "Latest LTS release",
                        10L
                )
        );

        when(versionService.getByTechnology(10L)).thenReturn(versions);

        mockMvc.perform(get("/versions")
                        .param("technology", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].versionCode").value(1))
                .andExpect(jsonPath("$[0].name").value("Java 17"))
                .andExpect(jsonPath("$[0].releaseDate").value("2021-09-14"))
                .andExpect(jsonPath("$[0].endOfLife").value("2029-09-14"))
                .andExpect(jsonPath("$[0].newFeatures").value("Sealed classes, pattern matching"))
                .andExpect(jsonPath("$[0].developerPopularity").value(4.8))
                .andExpect(jsonPath("$[0].communitySupport").value(4.9))
                .andExpect(jsonPath("$[0].industryUsageScore").value(4.7))
                .andExpect(jsonPath("$[0].knowledgeScore").value(4.6))
                .andExpect(jsonPath("$[0].skillsRating").value(4.8))
                .andExpect(jsonPath("$[0].rating").value(4.85))
                .andExpect(jsonPath("$[0].description").value("LTS release"))
                .andExpect(jsonPath("$[0].technologyCode").value(10));
    }
}

