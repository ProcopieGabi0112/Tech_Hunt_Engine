package com.techhunter.tech_hunter_engine_api.controller.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CountryDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.CountryService;
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
class CountryControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CountryService countryService;

    @Test
    void getCountriesByRegion_shouldReturnList() throws Exception {

        List<CountryDTO> countries = List.of(
                new CountryDTO(
                        1L,
                        "Romania",
                        "RO",
                        19000000L,
                        238397L,
                        "EET",
                        5.2,
                        8.1,
                        900.0,
                        16.0,
                        4.5,
                        10L,
                        1L,
                        1L
                ),
                new CountryDTO(
                        2L,
                        "Bulgaria",
                        "BG",
                        7000000L,
                        110994L,
                        "EET",
                        4.8,
                        7.3,
                        750.0,
                        15.0,
                        4.0,
                        10L,
                        1L,
                        1L
                )
        );

        when(countryService.getCountriesByRegion(10L)).thenReturn(countries);

        mockMvc.perform(get("/countries")
                        .param("regionId", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].countryId").value(1))
                .andExpect(jsonPath("$[0].name").value("Romania"))
                .andExpect(jsonPath("$[0].code").value("RO"))
                .andExpect(jsonPath("$[0].population").value(19000000))
                .andExpect(jsonPath("$[0].area").value(238397))
                .andExpect(jsonPath("$[0].timeZone").value("EET"))
                .andExpect(jsonPath("$[0].unemploymentRate").value(5.2))
                .andExpect(jsonPath("$[0].inflationRate").value(8.1))
                .andExpect(jsonPath("$[0].averageMonthlySalary").value(900.0))
                .andExpect(jsonPath("$[0].corporateTaxRate").value(16.0))
                .andExpect(jsonPath("$[0].rating").value(4.5))
                .andExpect(jsonPath("$[0].regionId").value(10))
                .andExpect(jsonPath("$[0].languageId").value(1))
                .andExpect(jsonPath("$[0].currencyId").value(1));
    }
}

