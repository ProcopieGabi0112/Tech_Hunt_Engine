package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UserSkillResponseDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.UserSkillMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.UserSkillEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.SkillRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.UserSkillRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserSkillServiceImplTest {

    @Mock
    private UserSkillRepository userSkillRepository;

    @Mock
    private SkillRepository skillRepository;

    @Mock
    private UserSkillMapper userSkillMapper;

    @InjectMocks
    private UserSkillServiceImpl service;

    @Test
    void getUserSkills_shouldReturnMappedDTOs() {

        UserSkillEntity entity = new UserSkillEntity();
        entity.setUserId(10L);
        entity.setSkillCode(100L);

        UserSkillResponseDTO dto = UserSkillResponseDTO.builder()
                .skillCode(100L)
                .skillName("Streams API")
                .versionName("Java 17")
                .technologyName("Java")
                .technologyTypeName("Programming Language")
                .proficiencyLevel(new BigDecimal("75.50"))
                .experienceMonths(24)
                .lastUsedDate(LocalDate.of(2024, 10, 1))
                .confidenceScore(new BigDecimal("88.00"))
                .build();

        when(userSkillRepository.findByUserIdAndDeletedFlag(10L, "N"))
                .thenReturn(List.of(entity));

        when(userSkillMapper.toDto(entity))
                .thenReturn(dto);

        List<UserSkillResponseDTO> result = service.getUserSkills(10L);

        assertEquals(1, result.size());
        assertEquals(100L, result.get(0).getSkillCode());
        assertEquals("Streams API", result.get(0).getSkillName());
        assertEquals("Java 17", result.get(0).getVersionName());
        assertEquals("Java", result.get(0).getTechnologyName());
        assertEquals("Programming Language", result.get(0).getTechnologyTypeName());
        assertEquals(new BigDecimal("75.50"), result.get(0).getProficiencyLevel());
        assertEquals(24, result.get(0).getExperienceMonths());
        assertEquals(LocalDate.of(2024, 10, 1), result.get(0).getLastUsedDate());
        assertEquals(new BigDecimal("88.00"), result.get(0).getConfidenceScore());
    }
}


