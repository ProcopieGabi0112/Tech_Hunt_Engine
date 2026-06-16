package com.techhunter.tech_hunter_engine_api.controller.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CityDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.CityService;
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
class CityControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CityService cityService;

    @Test
    void getCitiesByAdminUnit_shouldReturnList() throws Exception {

        List<CityDTO> cities = List.of(
                new CityDTO(
                        1L,
                        "City One",
                        150000L,
                        120L,
                        "N",
                        45.123,
                        25.456,
                        "Description 1",
                        10L
                ),
                new CityDTO(
                        2L,
                        "City Two",
                        250000L,
                        200L,
                        "Y",
                        46.789,
                        26.987,
                        "Description 2",
                        10L
                )
        );

        when(cityService.getCitiesByAdministrativeUnit(10L)).thenReturn(cities);

        mockMvc.perform(get("/cities")
                        .param("administrativeUnitId", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].cityCode").value(1))
                .andExpect(jsonPath("$[0].name").value("City One"))
                .andExpect(jsonPath("$[0].population").value(150000))
                .andExpect(jsonPath("$[0].area").value(120))
                .andExpect(jsonPath("$[0].isCapital").value("N"))
                .andExpect(jsonPath("$[0].latitude").value(45.123))
                .andExpect(jsonPath("$[0].longitude").value(25.456))
                .andExpect(jsonPath("$[0].description").value("Description 1"))
                .andExpect(jsonPath("$[0].administrativeUnitId").value(10));
    }
}

