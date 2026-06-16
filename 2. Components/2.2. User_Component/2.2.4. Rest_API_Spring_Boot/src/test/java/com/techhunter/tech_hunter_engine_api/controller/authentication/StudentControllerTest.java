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
class StudentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    // -----------------------------------------------------
    // STUDENT DASHBOARD
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "STUDENT")
    void studentDashboard_shouldReturn200_whenStudent() throws Exception {
        mockMvc.perform(get("/student/dashboard"))
                .andExpect(status().isOk())
                .andExpect(content().string("Student dashboard data"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void studentDashboard_shouldReturn403_whenNotStudent() throws Exception {
        mockMvc.perform(get("/student/dashboard"))
                .andExpect(status().isForbidden());
    }

    // -----------------------------------------------------
    // STUDENT PROFILE
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "STUDENT")
    void studentProfile_shouldReturn200_whenStudent() throws Exception {
        mockMvc.perform(get("/student/profile"))
                .andExpect(status().isOk())
                .andExpect(content().string("Student profile data"));
    }

    @Test
    @WithMockUser(roles = "USER")
    void studentProfile_shouldReturn403_whenNotStudent() throws Exception {
        mockMvc.perform(get("/student/profile"))
                .andExpect(status().isForbidden());
    }
}

