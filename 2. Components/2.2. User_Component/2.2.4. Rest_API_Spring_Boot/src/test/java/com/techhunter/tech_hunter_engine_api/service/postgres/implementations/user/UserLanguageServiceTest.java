package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.AddUserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UpdateUserLanguageDateDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LangLevelEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LanguageEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserLevelEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.certification.LangLevelRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserLevelRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserLanguageServiceTest {

    @Mock
    private UserLevelRepository userLevelRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private LangLevelRepository langLevelRepository;

    @InjectMocks
    private UserLanguageService userLanguageService;

    // -----------------------------------------------------
    // GET USER LANGUAGES
    // -----------------------------------------------------
    @Test
    void getUserLanguages_shouldReturnMappedDTOs() {

        // mock language
        var language = new LanguageEntity();
        language.setName("English");
        language.setIsoCode("EN");

        // mock lang level
        var level = new LangLevelEntity();
        level.setLangLevelId(10L);
        level.setLanguage(language);
        level.setName("B2");
        level.setNivel("Intermediate");
        level.setValidityPeriod(24);

        // mock user level
        var userLevel = new UserLevelEntity();
        userLevel.setLangLevel(level);
        userLevel.setObtainedDate(LocalDate.now());

        when(userLevelRepository.findByUser_UserId(1L))
                .thenReturn(List.of(userLevel));

        List<UserLanguageDTO> result = userLanguageService.getUserLanguages(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).langLevelId());
        assertEquals("English", result.get(0).languageName());
        assertEquals("EN", result.get(0).isoCode());
        assertEquals("B2", result.get(0).certificationName());
    }

    // -----------------------------------------------------
    // ADD USER LANGUAGE
    // -----------------------------------------------------
    @Test
    void addUserLanguage_shouldThrowException_whenAlreadyExists() {

        AddUserLanguageDTO dto = new AddUserLanguageDTO(10L, LocalDate.now());

        when(userLevelRepository.existsByUser_UserIdAndLangLevel_LangLevelId(1L, 10L))
                .thenReturn(true);

        assertThrows(RuntimeException.class,
                () -> userLanguageService.addUserLanguage(1L, dto));
    }

    @Test
    void addUserLanguage_shouldSaveEntity_whenValid() {

        AddUserLanguageDTO dto = new AddUserLanguageDTO(10L, LocalDate.now());

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        LangLevelEntity level = new LangLevelEntity();
        level.setLangLevelId(10L);

        when(userLevelRepository.existsByUser_UserIdAndLangLevel_LangLevelId(1L, 10L))
                .thenReturn(false);

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));

        when(langLevelRepository.findById(10L))
                .thenReturn(Optional.of(level));

        userLanguageService.addUserLanguage(1L, dto);

        verify(userLevelRepository).save(any(UserLevelEntity.class));
    }

    // -----------------------------------------------------
    // DELETE USER LANGUAGE
    // -----------------------------------------------------
    @Test
    void deleteUserLanguage_shouldCallRepository() {

        userLanguageService.deleteUserLanguage(1L, 10L);

        verify(userLevelRepository)
                .deleteByUser_UserIdAndLangLevel_LangLevelId(1L, 10L);
    }

    // -----------------------------------------------------
    // UPDATE USER LANGUAGE DATE
    // -----------------------------------------------------
    @Test
    void updateUserLanguageDate_shouldThrowException_whenNotFound() {

        when(userLevelRepository.findByUser_UserIdAndLangLevel_LangLevelId(1L, 10L))
                .thenReturn(Optional.empty());

        UpdateUserLanguageDateDTO dto = new UpdateUserLanguageDateDTO(LocalDate.now());

        assertThrows(RuntimeException.class,
                () -> userLanguageService.updateUserLanguageDate(1L, 10L, dto));
    }

    @Test
    void updateUserLanguageDate_shouldUpdateFields_whenFound() {

        UserLevelEntity entity = new UserLevelEntity();

        when(userLevelRepository.findByUser_UserIdAndLangLevel_LangLevelId(1L, 10L))
                .thenReturn(Optional.of(entity));

        UpdateUserLanguageDateDTO dto = new UpdateUserLanguageDateDTO(LocalDate.now());

        userLanguageService.updateUserLanguageDate(1L, 10L, dto);

        assertEquals(dto.obtainedDate(), entity.getObtainedDate());
        assertEquals("system", entity.getLastUpdatedBy());
        assertNotNull(entity.getLastUpdateDate());
    }
}
