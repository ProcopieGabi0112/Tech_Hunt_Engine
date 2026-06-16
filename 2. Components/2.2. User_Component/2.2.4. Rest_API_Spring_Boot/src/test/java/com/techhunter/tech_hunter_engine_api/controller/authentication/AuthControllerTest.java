package com.techhunter.tech_hunter_engine_api.controller.authentication;

import com.techhunter.tech_hunter_engine_api.config.security.JwtAuthFilter;
import com.techhunter.tech_hunter_engine_api.config.security.JwtService;
import com.techhunter.tech_hunter_engine_api.config.security.SecurityConfig;
import com.techhunter.tech_hunter_engine_api.controller.postgres.authentication.AuthController;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthResponse;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication.AuthService;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.authentication.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

// IMPORTURI MOCKMVC — OBLIGATORII
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false) // 🔥 dezactivează securitatea
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    // 🔥 mock-uim securitatea ca să nu pice contextul
    @MockBean private JwtAuthFilter jwtAuthFilter;
    @MockBean private JwtService jwtService;
    @MockBean private SecurityConfig securityConfig;

    @MockBean private AuthService authService;
    @MockBean private UserService userService;

    // -----------------------------------------------------
    // LOGIN
    // -----------------------------------------------------
    @Test
    void login_shouldReturnCookieAndResponse() throws Exception {

        AuthResponse response = AuthResponse.builder()
                .token("mock-token")
                .roleId(1L)
                .roleName("ADMIN")
                .build();

        when(authService.login(any())).thenReturn(response);

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"gabi@mail.com\",\"password\":\"pass\"}")
                .header("Host", "192.168.50.233:3000"))
                        .andExpect(status().isOk())
                        .andExpect(header().exists(HttpHeaders.SET_COOKIE))
                        .andExpect(jsonPath("$.token").value("mock-token"))
                        .andExpect(jsonPath("$.roleId").value(1))
                        .andExpect(jsonPath("$.roleName").value("ADMIN"));
    }

    // -----------------------------------------------------
    // REGISTER
    // -----------------------------------------------------
    @Test
    void register_shouldReturnAuthResponse() throws Exception {

        AuthResponse response = AuthResponse.builder()
                .token("reg-token")
                .roleId(2L)
                .roleName("USER")
                .build();

        when(authService.register(any())).thenReturn(response);

        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"new@mail.com\",\"password\":\"123\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("reg-token"))
                .andExpect(jsonPath("$.roleId").value(2))
                .andExpect(jsonPath("$.roleName").value("USER"));
    }

    // -----------------------------------------------------
    // FORGOT PASSWORD
    // -----------------------------------------------------
    @Test
    void forgotPassword_shouldCallService() throws Exception {

        mockMvc.perform(post("/auth/forgot-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"test@mail.com\"}"))
                .andExpect(status().isOk())
                .andExpect(content().string("If the email exists, a reset link was sent."));

        verify(userService).generateResetToken("test@mail.com");
    }

    // -----------------------------------------------------
    // RESET PASSWORD
    // -----------------------------------------------------
    @Test
    void resetPassword_shouldCallService() throws Exception {

        mockMvc.perform(post("/auth/reset-password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"token\":\"abc\",\"newPassword\":\"xyz\"}"))
                .andExpect(status().isOk())
                .andExpect(content().string("Password updated successfully"));

        verify(userService).resetPassword("abc", "xyz");
    }
}
