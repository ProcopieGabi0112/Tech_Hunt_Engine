package com.techhunter.tech_hunter_engine_api.controller.authentication;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class ManagerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    // -----------------------------------------------------
    // MANAGER DASHBOARD
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "MANAGER")
    void managerDashboard_shouldReturn200_whenManager() throws Exception {
        mockMvc.perform(get("/manager/dashboard"))
                .andExpect(status().isOk())
                .andExpect(content().string("Manager dashboard data"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void managerDashboard_shouldReturn403_whenNotManager() throws Exception {
        mockMvc.perform(get("/manager/dashboard"))
                .andExpect(status().isForbidden());
    }

    // -----------------------------------------------------
    // MANAGER TEAM
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "MANAGER")
    void managerTeam_shouldReturn200_whenManager() throws Exception {
        mockMvc.perform(get("/manager/team"))
                .andExpect(status().isOk())
                .andExpect(content().string("Manager team data"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void managerTeam_shouldReturn403_whenNotManager() throws Exception {
        mockMvc.perform(get("/manager/team"))
                .andExpect(status().isForbidden());
    }
}

