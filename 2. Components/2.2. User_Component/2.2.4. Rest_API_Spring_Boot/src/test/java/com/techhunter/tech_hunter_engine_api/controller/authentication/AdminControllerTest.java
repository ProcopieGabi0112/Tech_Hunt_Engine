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
class AdminControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(roles = "ADMIN")
    void adminDashboard_shouldReturn200_whenAdmin() throws Exception {
        mockMvc.perform(get("/admin/dashboard"))
                .andExpect(status().isOk())
                .andExpect(content().string("Admin dashboard data"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void adminDashboard_shouldReturn403_whenNotAdmin() throws Exception {
        mockMvc.perform(get("/admin/dashboard"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void adminStats_shouldReturn200_whenAdmin() throws Exception {
        mockMvc.perform(get("/admin/stats"))
                .andExpect(status().isOk())
                .andExpect(content().string("Admin statistics"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void adminStats_shouldReturn403_whenNotAdmin() throws Exception {
        mockMvc.perform(get("/admin/stats"))
                .andExpect(status().isForbidden());
    }
}

