package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.AddUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UpdateUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UserSkillResponseDTO;

import java.util.List;

public interface UserSkillService {
    List<UserSkillResponseDTO> getUserSkills(Long userId);
    void addUserSkill(Long userId, AddUserSkillDTO dto);
    void updateUserSkill(Long userId, Long skillCode, UpdateUserSkillDTO dto);
    void deleteUserSkill(Long userId, Long skillCode);
}
