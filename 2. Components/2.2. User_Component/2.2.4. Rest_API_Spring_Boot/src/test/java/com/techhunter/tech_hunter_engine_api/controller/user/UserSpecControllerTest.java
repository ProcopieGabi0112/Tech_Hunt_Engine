package com.techhunter.tech_hunter_engine_api.controller.user;

import com.techhunter.tech_hunter_engine_api.config.security.UserDetailsImpl;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecViewDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user.UserSpecService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.core.Authentication;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.security.Principal;
import java.time.LocalDate;
import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
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
class UserSpecControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserSpecService userSpecService;

    private Principal mockPrincipal(Long userId) {
        Authentication auth = mock(Authentication.class);
        UserDetailsImpl details = mock(UserDetailsImpl.class);

        when(details.getUserId()).thenReturn(userId);
        when(auth.getPrincipal()).thenReturn(details);

        return (Principal) auth;
    }

    @Test
    void getMySpecializations_shouldReturnList() throws Exception {

        List<UserSpecDTO> specs = List.of(
                new UserSpecDTO(1L, 99L, LocalDate.of(2022, 6, 1)),
                new UserSpecDTO(2L, 99L, LocalDate.of(2023, 7, 15))
        );

        when(userSpecService.getUserSpecializations(99L)).thenReturn(specs);

        mockMvc.perform(get("/users/me/specializations")
                        .principal(mockPrincipal(99L)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].specializationId").value(1))
                .andExpect(jsonPath("$[0].userId").value(99))
                .andExpect(jsonPath("$[0].graduationDate").value("2022-06-01"));
    }

    @Test
    void addSpecialization_shouldCallService() throws Exception {

        mockMvc.perform(post("/users/me/specializations")
                        .principal(mockPrincipal(99L))
                        .contentType("application/json")
                        .content("""
                                {
                                  "specializationId": 5,
                                  "userId": 0,
                                  "graduationDate": "2024-02-01"
                                }
                                """))
                .andExpect(status().isOk());

        verify(userSpecService).addUserSpecialization(any(UserSpecDTO.class));
    }

    @Test
    void getMySpecializationsView_shouldReturnList() throws Exception {

        List<UserSpecViewDTO> view = List.of(
                new UserSpecViewDTO(
                        1L,
                        "Computer Science",
                        "Tech University",
                        "Bucharest",
                        "Romania",
                        LocalDate.of(2022, 6, 1)
                ),
                new UserSpecViewDTO(
                        2L,
                        "Software Engineering",
                        "Science Academy",
                        "Cluj-Napoca",
                        "Romania",
                        LocalDate.of(2023, 7, 15)
                )
        );

        when(userSpecService.getUserSpecializationsView(99L)).thenReturn(view);

        mockMvc.perform(get("/users/me/specializations/view")
                        .principal(mockPrincipal(99L)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].specializationId").value(1))
                .andExpect(jsonPath("$[0].specializationName").value("Computer Science"))
                .andExpect(jsonPath("$[0].institutionName").value("Tech University"))
                .andExpect(jsonPath("$[0].cityName").value("Bucharest"))
                .andExpect(jsonPath("$[0].countryName").value("Romania"))
                .andExpect(jsonPath("$[0].graduationDate").value("2022-06-01"))
                .andExpect(jsonPath("$[1].specializationId").value(2))
                .andExpect(jsonPath("$[1].specializationName").value("Software Engineering"))
                .andExpect(jsonPath("$[1].institutionName").value("Science Academy"))
                .andExpect(jsonPath("$[1].cityName").value("Cluj-Napoca"))
                .andExpect(jsonPath("$[1].countryName").value("Romania"))
                .andExpect(jsonPath("$[1].graduationDate").value("2023-07-15"));
    }

    @Test
    void updateGraduationDate_shouldCallService() throws Exception {

        mockMvc.perform(put("/users/me/specializations/7")
                        .principal(mockPrincipal(99L))
                        .contentType("application/json")
                        .content("""
                                {
                                  "graduationDate": "2024-03-10"
                                }
                                """))
                .andExpect(status().isOk());

        verify(userSpecService).updateGraduationDate(99L, 7L, LocalDate.parse("2024-03-10"));
    }

    @Test
    void deleteSpecialization_shouldCallService() throws Exception {

        mockMvc.perform(delete("/users/me/specializations/3")
                        .principal(mockPrincipal(99L)))
                .andExpect(status().isOk());

        verify(userSpecService).deleteSpecialization(99L, 3L);
    }
}

