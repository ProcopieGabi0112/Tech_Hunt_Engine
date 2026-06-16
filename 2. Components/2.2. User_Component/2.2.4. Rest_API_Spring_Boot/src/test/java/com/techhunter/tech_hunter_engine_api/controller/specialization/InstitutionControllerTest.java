package com.techhunter.tech_hunter_engine_api.controller.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.InstitutionDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization.InstitutionService;
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
class InstitutionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private InstitutionService institutionService;

    @Test
    void getInstitutionsByLocation_shouldReturnList() throws Exception {

        List<InstitutionDTO> institutions = List.of(
                new InstitutionDTO(
                        1L,
                        "Tech University",
                        "https://techuniversity.example.com",
                        "1965",
                        4.7,
                        "Top engineering institution",
                        100L
                ),
                new InstitutionDTO(
                        2L,
                        "Science Academy",
                        "https://scienceacademy.example.com",
                        "1978",
                        4.5,
                        "Leading science research academy",
                        100L
                )
        );

        when(institutionService.getInstitutionsByLocation(100L)).thenReturn(institutions);

        mockMvc.perform(get("/institutions")
                        .param("locationId", "100"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].institutionId").value(1))
                .andExpect(jsonPath("$[0].name").value("Tech University"))
                .andExpect(jsonPath("$[0].website").value("https://techuniversity.example.com"))
                .andExpect(jsonPath("$[0].foundingYear").value("1965"))
                .andExpect(jsonPath("$[0].rating").value(4.7))
                .andExpect(jsonPath("$[0].description").value("Top engineering institution"))
                .andExpect(jsonPath("$[0].locationId").value(100))
                .andExpect(jsonPath("$[1].institutionId").value(2))
                .andExpect(jsonPath("$[1].name").value("Science Academy"))
                .andExpect(jsonPath("$[1].website").value("https://scienceacademy.example.com"))
                .andExpect(jsonPath("$[1].foundingYear").value("1978"))
                .andExpect(jsonPath("$[1].rating").value(4.5))
                .andExpect(jsonPath("$[1].description").value("Leading science research academy"))
                .andExpect(jsonPath("$[1].locationId").value(100));
    }
}

