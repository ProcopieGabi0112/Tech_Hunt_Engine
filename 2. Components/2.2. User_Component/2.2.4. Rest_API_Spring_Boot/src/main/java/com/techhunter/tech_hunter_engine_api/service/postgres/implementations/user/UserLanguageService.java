package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.AddUserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UpdateUserLanguageDateDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.UserLevelId;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserLevelEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.certification.LangLevelRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserLevelRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserLanguageService {

    private final UserLevelRepository userLevelRepository;
    private final UserRepository userRepository;
    private final LangLevelRepository langLevelRepository;

    public List<UserLanguageDTO> getUserLanguages(Long userId) {
        return userLevelRepository.findByUser_UserId(userId)
                .stream()
                .map(ul -> new UserLanguageDTO(
                        ul.getLangLevel().getLangLevelId(),
                        ul.getLangLevel().getLanguage().getName(),
                        ul.getLangLevel().getLanguage().getIsoCode(),
                        ul.getLangLevel().getName(),
                        ul.getLangLevel().getNivel(),
                        ul.getLangLevel().getLanguage().getRating(),
                        ul.getLangLevel().getRating(),
                        ul.getLangLevel().getValidityPeriod(),
                        ul.getObtainedDate()
                ))
                .toList();
    }

    @Transactional
    public void addUserLanguage(Long userId, AddUserLanguageDTO dto) {

        if (userLevelRepository.existsByUser_UserIdAndLangLevel_LangLevelId(userId, dto.langLevelId())) {
            throw new RuntimeException("User already has this certification");
        }

        var user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        var level = langLevelRepository.findById(dto.langLevelId())
                .orElseThrow(() -> new RuntimeException("Certification not found"));

        var id = new UserLevelId(userId, dto.langLevelId());

        var entity = new UserLevelEntity();
        entity.setId(id);
        entity.setUser(user);
        entity.setLangLevel(level);
        entity.setObtainedDate(dto.obtainedDate());

        // 🔥 Coloane tehnice obligatorii
        entity.setCreatedBy("system");
        entity.setLastUpdatedBy("system");
        entity.setSourceSystem("pg_env");
        entity.setSyncStatus("synced");
        entity.setSyncVersion(1L);
        entity.setDeletedFlag("N");
        entity.setLastSyncedAt(LocalDateTime.now()); // 🔥 FIX

        userLevelRepository.save(entity);
    }

    @Transactional
    public void deleteUserLanguage(Long userId, Long langLevelId) {
        userLevelRepository.deleteByUser_UserIdAndLangLevel_LangLevelId(userId, langLevelId);
    }

    @Transactional
    public void updateUserLanguageDate(Long userId, Long langLevelId, UpdateUserLanguageDateDTO dto) {

        var entity = userLevelRepository
                .findByUser_UserIdAndLangLevel_LangLevelId(userId, langLevelId)
                .orElseThrow(() -> new RuntimeException("Certification not found"));

        entity.setObtainedDate(dto.obtainedDate());
        entity.setLastUpdatedBy("system");
        entity.setLastUpdateDate(LocalDateTime.now());
    }
}
