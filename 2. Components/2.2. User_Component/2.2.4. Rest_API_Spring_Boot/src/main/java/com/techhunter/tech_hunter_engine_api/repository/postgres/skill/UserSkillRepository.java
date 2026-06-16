package com.techhunter.tech_hunter_engine_api.repository.postgres.skill;

import com.techhunter.tech_hunter_engine_api.model.postgres.skill.UserSkillEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.UserSkillId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserSkillRepository extends JpaRepository<UserSkillEntity, UserSkillId> {
    List<UserSkillEntity> findByUserIdAndDeletedFlag(Long userId, String deletedFlag);
    Optional<UserSkillEntity> findByUserIdAndSkillCodeAndDeletedFlag(Long userId, Long skillCode, String deletedFlag);
}