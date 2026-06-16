package com.techhunter.tech_hunter_engine_api.controller.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.AdministrativeUnitService;
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
class AdministrativeUnitControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AdministrativeUnitService administrativeUnitService;

    @Test
    void getUnitsByCountry_shouldReturnList() throws Exception {

        List<AdministrativeUnitDTO> units = List.of(
                new AdministrativeUnitDTO(
                        1L,
                        "Unit 1",
                        "U1",
                        100000L,
                        500L,
                        10L,
                        "Description 1",
                        2L,
                        "County",
                        1L
                ),
                new AdministrativeUnitDTO(
                        2L,
                        "Unit 2",
                        "U2",
                        200000L,
                        800L,
                        20L,
                        "Description 2",
                        2L,
                        "County",
                        1L
                )
        );

        when(administrativeUnitService.getUnitsByCountry(1L)).thenReturn(units);

        mockMvc.perform(get("/admin-units")
                        .param("countryId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].administrativeUnitId").value(1))
                .andExpect(jsonPath("$[0].name").value("Unit 1"))
                .andExpect(jsonPath("$[0].code").value("U1"))
                .andExpect(jsonPath("$[0].population").value(100000))
                .andExpect(jsonPath("$[0].area").value(500))
                .andExpect(jsonPath("$[0].numberOfCities").value(10))
                .andExpect(jsonPath("$[0].description").value("Description 1"))
                .andExpect(jsonPath("$[0].administrativeUnitTypeId").value(2))
                .andExpect(jsonPath("$[0].administrativeUnitTypeName").value("County"))
                .andExpect(jsonPath("$[0].countryId").value(1));
    }
}


