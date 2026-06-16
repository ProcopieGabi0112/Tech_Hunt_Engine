package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.AddUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UpdateUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UserSkillResponseDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.UserSkillMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.SkillEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.skill.UserSkillEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.SkillRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.UserSkillRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.UserSkillService;

import jakarta.transaction.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserSkillServiceImpl implements UserSkillService {

    private final UserSkillRepository userSkillRepository;
    private final SkillRepository skillRepository;
    private final UserSkillMapper userSkillMapper;

    public UserSkillServiceImpl(UserSkillRepository userSkillRepository,
                                SkillRepository skillRepository,
                                UserSkillMapper userSkillMapper) {
        this.userSkillRepository = userSkillRepository;
        this.skillRepository = skillRepository;
        this.userSkillMapper = userSkillMapper;
    }

    @Override
    public List<UserSkillResponseDTO> getUserSkills(Long userId) {
        return userSkillRepository.findByUserIdAndDeletedFlag(userId, "N")
                .stream()
                .map(userSkillMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void addUserSkill(Long userId, AddUserSkillDTO dto) {
        // defensive validations
        if (dto.getProficiencyLevel().compareTo(BigDecimal.ZERO) < 0 ||
                dto.getProficiencyLevel().compareTo(new BigDecimal("100.00")) > 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Proficiency must be between 0.00 and 100.00");
        }
        if (dto.getLastUsedDate().isAfter(LocalDate.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Last used date cannot be in the future");
        }

        // check skill exists
        SkillEntity skill = skillRepository.findById(dto.getSkillCode())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Skill not found"));

        // check duplicate
        if (userSkillRepository.findByUserIdAndSkillCodeAndDeletedFlag(userId, dto.getSkillCode(), "N").isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User already has this skill");
        }

        UserSkillEntity entity = new UserSkillEntity();
        entity.setUserId(userId);
        entity.setSkillCode(dto.getSkillCode());
        entity.setProficiencyLevel(dto.getProficiencyLevel());
        entity.setExperienceMonths(dto.getExperienceMonths());
        entity.setLastUsedDate(dto.getLastUsedDate());
        entity.setConfidenceScore(dto.getConfidenceScore());
        // audit
        entity.setCreationDate(LocalDateTime.now());
        entity.setCreatedBy("db_owner"); // replace with current user
        entity.setLastUpdateDate(LocalDateTime.now());
        entity.setLastUpdatedBy("db_owner");
        entity.setSourceSystem("pg_env");
        entity.setSyncStatus("synced");
        entity.setSyncVersion(1L);
        entity.setLastSyncedAt(LocalDateTime.now());
        entity.setDeletedFlag("N");

        userSkillRepository.save(entity);
    }

    @Override
    @Transactional
    public void updateUserSkill(Long userId, Long skillCode, UpdateUserSkillDTO dto) {
        UserSkillEntity entity = userSkillRepository.findByUserIdAndSkillCodeAndDeletedFlag(userId, skillCode, "N")
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSkill not found"));

        if (dto.getProficiencyLevel() != null) {
            if (dto.getProficiencyLevel().compareTo(BigDecimal.ZERO) < 0 ||
                    dto.getProficiencyLevel().compareTo(new BigDecimal("100.00")) > 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Proficiency must be between 0.00 and 100.00");
            }
            entity.setProficiencyLevel(dto.getProficiencyLevel());
        }

        if (dto.getExperienceMonths() != null) {
            if (dto.getExperienceMonths() < 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Experience months must be >= 0");
            }
            entity.setExperienceMonths(dto.getExperienceMonths());
        }

        if (dto.getLastUsedDate() != null) {
            if (dto.getLastUsedDate().isAfter(LocalDate.now())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Last used date cannot be in the future");
            }
            entity.setLastUsedDate(dto.getLastUsedDate());
        }

        if (dto.getConfidenceScore() != null) {
            if (dto.getConfidenceScore().compareTo(BigDecimal.ZERO) < 0 ||
                    dto.getConfidenceScore().compareTo(new BigDecimal("100.00")) > 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Confidence must be between 0.00 and 100.00");
            }
            entity.setConfidenceScore(dto.getConfidenceScore());
        }

        // audit
        entity.setLastUpdateDate(LocalDateTime.now());
        entity.setLastUpdatedBy("system");

        userSkillRepository.save(entity);
    }

    @Override
    @Transactional
    public void deleteUserSkill(Long userId, Long skillCode) {
        UserSkillEntity entity = userSkillRepository.findByUserIdAndSkillCodeAndDeletedFlag(userId, skillCode, "N")
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "UserSkill not found"));

        // soft delete
        entity.setDeletedFlag("Y");
        entity.setLastUpdateDate(LocalDateTime.now());
        entity.setLastUpdatedBy("system");

        userSkillRepository.save(entity);
    }
}
