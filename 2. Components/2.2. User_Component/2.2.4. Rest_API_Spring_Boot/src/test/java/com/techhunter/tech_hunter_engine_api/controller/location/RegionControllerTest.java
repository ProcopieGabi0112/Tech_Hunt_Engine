package com.techhunter.tech_hunter_engine_api.controller.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.RegionDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.RegionService;
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
class RegionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private RegionService regionService;

    @Test
    void getRegions_shouldReturnList() throws Exception {

        List<RegionDTO> regions = List.of(
                new RegionDTO(
                        1L,
                        "Europe",
                        "EU",
                        "European region"
                ),
                new RegionDTO(
                        2L,
                        "Asia",
                        "AS",
                        "Asian region"
                )
        );

        when(regionService.getAllRegions()).thenReturn(regions);

        mockMvc.perform(get("/regions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].regionId").value(1))
                .andExpect(jsonPath("$[0].name").value("Europe"))
                .andExpect(jsonPath("$[0].code").value("EU"))
                .andExpect(jsonPath("$[0].description").value("European region"))
                .andExpect(jsonPath("$[1].regionId").value(2))
                .andExpect(jsonPath("$[1].name").value("Asia"))
                .andExpect(jsonPath("$[1].code").value("AS"))
                .andExpect(jsonPath("$[1].description").value("Asian region"));
    }
}

