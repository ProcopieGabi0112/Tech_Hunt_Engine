package com.techhunter.tech_hunter_engine_api.controller.user;

import com.techhunter.tech_hunter_engine_api.config.security.SecurityUtils;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.AddUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UpdateUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UserSkillResponseDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.UserSkillService;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
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
class UserSkillControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserSkillService userSkillService;

    @Test
    void getMySkills_shouldReturnList() throws Exception {

        List<UserSkillResponseDTO> skills = List.of(
                UserSkillResponseDTO.builder()
                        .skillCode(1L)
                        .skillName("Streams API")
                        .versionName("Java 17")
                        .technologyName("Java")
                        .technologyTypeName("Programming Language")
                        .proficiencyLevel(new BigDecimal("75.50"))
                        .experienceMonths(24)
                        .lastUsedDate(LocalDate.of(2024, 10, 1))
                        .confidenceScore(new BigDecimal("88.00"))
                        .build(),
                UserSkillResponseDTO.builder()
                        .skillCode(2L)
                        .skillName("Spring Boot")
                        .versionName("3.2")
                        .technologyName("Spring")
                        .technologyTypeName("Framework")
                        .proficiencyLevel(new BigDecimal("82.00"))
                        .experienceMonths(36)
                        .lastUsedDate(LocalDate.of(2024, 5, 15))
                        .confidenceScore(new BigDecimal("90.00"))
                        .build()
        );

        try (MockedStatic<SecurityUtils> mocked = Mockito.mockStatic(SecurityUtils.class)) {
            mocked.when(SecurityUtils::getCurrentUserIdFromContext).thenReturn(99L);

            when(userSkillService.getUserSkills(99L)).thenReturn(skills);

            mockMvc.perform(get("/users/me/skills"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$[0].skillCode").value(1))
                    .andExpect(jsonPath("$[0].skillName").value("Streams API"))
                    .andExpect(jsonPath("$[0].versionName").value("Java 17"))
                    .andExpect(jsonPath("$[0].technologyName").value("Java"))
                    .andExpect(jsonPath("$[0].technologyTypeName").value("Programming Language"))
                    .andExpect(jsonPath("$[0].proficiencyLevel").value(75.50))
                    .andExpect(jsonPath("$[0].experienceMonths").value(24))
                    .andExpect(jsonPath("$[0].lastUsedDate").value("2024-10-01"))
                    .andExpect(jsonPath("$[0].confidenceScore").value(88.00));
        }
    }

    @Test
    void addSkill_shouldCallService() throws Exception {

        AddUserSkillDTO dto = new AddUserSkillDTO(5L, new BigDecimal("80.00"), 12, LocalDate.of(2024, 1, 1), new BigDecimal("90.00"));

        try (MockedStatic<SecurityUtils> mocked = Mockito.mockStatic(SecurityUtils.class)) {
            mocked.when(SecurityUtils::getCurrentUserIdFromContext).thenReturn(99L);

            mockMvc.perform(post("/users/me/skills")
                            .contentType("application/json")
                            .content("""
                                    {
                                      "skillCode": 5,
                                      "proficiencyLevel": 80.00,
                                      "experienceMonths": 12,
                                      "lastUsedDate": "2024-01-01",
                                      "confidenceScore": 90.00
                                    }
                                    """))
                    .andExpect(status().isCreated());

            verify(userSkillService).addUserSkill(eq(99L), any(AddUserSkillDTO.class));
        }
    }

    @Test
    void updateSkill_shouldCallService() throws Exception {

        try (MockedStatic<SecurityUtils> mocked = Mockito.mockStatic(SecurityUtils.class)) {
            mocked.when(SecurityUtils::getCurrentUserIdFromContext).thenReturn(99L);

            mockMvc.perform(put("/users/me/skills/7")
                            .contentType("application/json")
                            .content("""
                                    {
                                      "proficiencyLevel": 85.00,
                                      "experienceMonths": 30,
                                      "lastUsedDate": "2024-03-10",
                                      "confidenceScore": 92.00
                                    }
                                    """))
                    .andExpect(status().isNoContent());

            verify(userSkillService).updateUserSkill(eq(99L), eq(7L), any(UpdateUserSkillDTO.class));
        }
    }

    @Test
    void deleteSkill_shouldCallService() throws Exception {

        try (MockedStatic<SecurityUtils> mocked = Mockito.mockStatic(SecurityUtils.class)) {
            mocked.when(SecurityUtils::getCurrentUserIdFromContext).thenReturn(99L);

            mockMvc.perform(delete("/users/me/skills/3"))
                    .andExpect(status().isNoContent());

            verify(userSkillService).deleteUserSkill(99L, 3L);
        }
    }
}

