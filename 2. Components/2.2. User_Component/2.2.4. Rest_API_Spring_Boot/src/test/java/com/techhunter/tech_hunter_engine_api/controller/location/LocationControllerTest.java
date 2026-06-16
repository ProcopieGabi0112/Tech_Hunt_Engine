package com.techhunter.tech_hunter_engine_api.controller.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.LocationDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.LocationService;
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
class LocationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LocationService locationService;

    @Test
    void getLocationsByCity_shouldReturnList() throws Exception {

        List<LocationDTO> locations = List.of(
                new LocationDTO(
                        1L,
                        "Main Street",
                        "10A",
                        "12345",
                        "Building A",
                        "1",
                        "2",
                        "10",
                        100L
                ),
                new LocationDTO(
                        2L,
                        "Second Street",
                        "22B",
                        "54321",
                        "Building B",
                        "2",
                        "3",
                        "20",
                        100L
                )
        );

        when(locationService.getLocationsByCity(100L)).thenReturn(locations);

        mockMvc.perform(get("/locations")
                        .param("cityCode", "100"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].locationId").value(1))
                .andExpect(jsonPath("$[0].streetName").value("Main Street"))
                .andExpect(jsonPath("$[0].streetNumber").value("10A"))
                .andExpect(jsonPath("$[0].postalCode").value("12345"))
                .andExpect(jsonPath("$[0].building").value("Building A"))
                .andExpect(jsonPath("$[0].staircase").value("1"))
                .andExpect(jsonPath("$[0].floor").value("2"))
                .andExpect(jsonPath("$[0].apartmentNumber").value("10"))
                .andExpect(jsonPath("$[0].cityCode").value(100));
    }
}

