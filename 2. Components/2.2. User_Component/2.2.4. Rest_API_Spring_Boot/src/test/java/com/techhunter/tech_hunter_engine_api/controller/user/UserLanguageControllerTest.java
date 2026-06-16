package com.techhunter.tech_hunter_engine_api.controller.user;

import com.techhunter.tech_hunter_engine_api.config.security.UserDetailsImpl;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.AddUserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UpdateUserLanguageDateDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user.UserLanguageService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.core.Authentication;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
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
class UserLanguageControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserLanguageService userLanguageService;

    private Principal mockPrincipal(Long userId) {
        Authentication auth = mock(Authentication.class);
        UserDetailsImpl details = mock(UserDetailsImpl.class);

        when(details.getUserId()).thenReturn(userId);
        when(auth.getPrincipal()).thenReturn(details);

        return (Principal) auth;
    }

    @Test
    void getUserLanguages_shouldReturnList() throws Exception {

        List<UserLanguageDTO> langs = List.of(
                new UserLanguageDTO(
                        1L,
                        "English",
                        "EN",
                        "Cambridge C1",
                        "C1",
                        new BigDecimal("4.8"),
                        new BigDecimal("4.7"),
                        24,
                        LocalDate.of(2023, 1, 10)
                ),
                new UserLanguageDTO(
                        2L,
                        "German",
                        "DE",
                        "Goethe B2",
                        "B2",
                        new BigDecimal("4.2"),
                        new BigDecimal("4.0"),
                        18,
                        LocalDate.of(2022, 5, 20)
                )
        );

        when(userLanguageService.getUserLanguages(99L)).thenReturn(langs);

        mockMvc.perform(get("/users/me/languages")
                        .principal(mockPrincipal(99L)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].langLevelId").value(1))
                .andExpect(jsonPath("$[0].languageName").value("English"))
                .andExpect(jsonPath("$[0].isoCode").value("EN"))
                .andExpect(jsonPath("$[0].certificationName").value("Cambridge C1"))
                .andExpect(jsonPath("$[0].nivel").value("C1"))
                .andExpect(jsonPath("$[0].ratingLanguage").value(4.8))
                .andExpect(jsonPath("$[0].ratingCertification").value(4.7))
                .andExpect(jsonPath("$[0].validityPeriod").value(24))
                .andExpect(jsonPath("$[0].obtainedDate").value("2023-01-10"));
    }

    @Test
    void addUserLanguage_shouldCallService() throws Exception {

        mockMvc.perform(post("/users/me/languages")
                        .principal(mockPrincipal(99L))
                        .contentType("application/json")
                        .content("""
                                {
                                  "langLevelId": 5,
                                  "obtainedDate": "2024-02-01"
                                }
                                """))
                .andExpect(status().isOk());

        verify(userLanguageService).addUserLanguage(eq(99L), any(AddUserLanguageDTO.class));
    }

    @Test
    void deleteUserLanguage_shouldCallService() throws Exception {

        mockMvc.perform(delete("/users/me/languages/7")
                        .principal(mockPrincipal(99L)))
                .andExpect(status().isOk());

        verify(userLanguageService).deleteUserLanguage(99L, 7L);
    }

    @Test
    void updateUserLanguageDate_shouldCallService() throws Exception {

        mockMvc.perform(put("/users/me/languages/3")
                        .principal(mockPrincipal(99L))
                        .contentType("application/json")
                        .content("""
                                {
                                  "obtainedDate": "2024-03-15"
                                }
                                """))
                .andExpect(status().isOk());

        verify(userLanguageService).updateUserLanguageDate(eq(99L), eq(3L), any(UpdateUserLanguageDateDTO.class));
    }
}
