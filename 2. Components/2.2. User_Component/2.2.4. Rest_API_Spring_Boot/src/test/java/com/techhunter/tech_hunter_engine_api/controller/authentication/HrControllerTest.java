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
class HrControllerTest {

    @Autowired
    private MockMvc mockMvc;

    // -----------------------------------------------------
    // HR DASHBOARD
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "SPECIALIST_HR")
    void hrDashboard_shouldReturn200_whenHr() throws Exception {
        mockMvc.perform(get("/hr/dashboard"))
                .andExpect(status().isOk())
                .andExpect(content().string("HR dashboard data"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void hrDashboard_shouldReturn403_whenNotHr() throws Exception {
        mockMvc.perform(get("/hr/dashboard"))
                .andExpect(status().isForbidden());
    }

    // -----------------------------------------------------
    // HR CANDIDATES
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "SPECIALIST_HR")
    void hrCandidates_shouldReturn200_whenHr() throws Exception {
        mockMvc.perform(get("/hr/candidates"))
                .andExpect(status().isOk())
                .andExpect(content().string("HR candidates list"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void hrCandidates_shouldReturn403_whenNotHr() throws Exception {
        mockMvc.perform(get("/hr/candidates"))
                .andExpect(status().isForbidden());
    }
}

