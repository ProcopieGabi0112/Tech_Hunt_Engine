package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecViewDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.user.UserSpecViewMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserSpecEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.SpecializationRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserSpecRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserSpecServiceImplTest {

    @Mock
    private UserSpecRepository userSpecRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SpecializationRepository specializationRepository;

    @Mock
    private UserSpecViewMapper userSpecViewMapper;

    @InjectMocks
    private UserSpecServiceImpl userSpecService;

    // -----------------------------------------------------
    // GET USER SPECIALIZATIONS
    // -----------------------------------------------------
    @Test
    void getUserSpecializations_shouldReturnMappedDTOs() {

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        SpecializationEntity spec = new SpecializationEntity();
        spec.setSpecializationId(10L);

        UserSpecEntity entity = new UserSpecEntity();
        entity.setUser(user);
        entity.setSpecialization(spec);
        entity.setGraduationDate(LocalDate.of(2020, 1, 1));

        when(userSpecRepository.findByUser_UserId(1L))
                .thenReturn(List.of(entity));

        List<UserSpecDTO> result = userSpecService.getUserSpecializations(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).specializationId());
        assertEquals(1L, result.get(0).userId());
        assertEquals(LocalDate.of(2020, 1, 1), result.get(0).graduationDate());
    }

    // -----------------------------------------------------
    // ADD USER SPECIALIZATION
    // -----------------------------------------------------
    @Test
    void addUserSpecialization_shouldThrow_whenUserNotFound() {

        UserSpecDTO dto = new UserSpecDTO(10L, 1L, LocalDate.now());

        when(userRepository.findById(1L))
                .thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> userSpecService.addUserSpecialization(dto));
    }

    @Test
    void addUserSpecialization_shouldThrow_whenSpecializationNotFound() {

        UserSpecDTO dto = new UserSpecDTO(10L, 1L, LocalDate.now());

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));

        when(specializationRepository.findById(10L))
                .thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> userSpecService.addUserSpecialization(dto));
    }

    @Test
    void addUserSpecialization_shouldSaveEntity_whenValid() {

        UserSpecDTO dto = new UserSpecDTO(10L, 1L, LocalDate.now());

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        SpecializationEntity spec = new SpecializationEntity();
        spec.setSpecializationId(10L);

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));

        when(specializationRepository.findById(10L))
                .thenReturn(Optional.of(spec));

        userSpecService.addUserSpecialization(dto);

        verify(userSpecRepository).save(any(UserSpecEntity.class));
    }

    // -----------------------------------------------------
    // GET USER SPECIALIZATIONS VIEW
    // -----------------------------------------------------
    @Test
    void getUserSpecializationsView_shouldMapEntities() {

        UserSpecEntity entity = new UserSpecEntity();

        UserSpecViewDTO dto = new UserSpecViewDTO(
                10L,
                "Computer Science",
                "MIT",
                "Boston",
                "USA",
                LocalDate.of(2020, 1, 1)
        );

        when(userSpecRepository.findByUser_UserId(1L))
                .thenReturn(List.of(entity));

        when(userSpecViewMapper.toDto(entity))
                .thenReturn(dto);

        List<UserSpecViewDTO> result = userSpecService.getUserSpecializationsView(1L);

        assertEquals(1, result.size());
        assertEquals(10L, result.get(0).getSpecializationId());
        assertEquals("Computer Science", result.get(0).getSpecializationName());
        assertEquals("MIT", result.get(0).getInstitutionName());
        assertEquals("Boston", result.get(0).getCityName());
        assertEquals("USA", result.get(0).getCountryName());
        assertEquals(LocalDate.of(2020, 1, 1), result.get(0).getGraduationDate());
    }

    // -----------------------------------------------------
    // UPDATE GRADUATION DATE
    // -----------------------------------------------------
    @Test
    void updateGraduationDate_shouldThrow_whenNotFound() {

        when(userSpecRepository.findByUser_UserIdAndSpecialization_SpecializationId(1L, 10L))
                .thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> userSpecService.updateGraduationDate(1L, 10L, LocalDate.now()));
    }

    @Test
    void updateGraduationDate_shouldUpdateAndSave() {

        UserSpecEntity entity = new UserSpecEntity();

        when(userSpecRepository.findByUser_UserIdAndSpecialization_SpecializationId(1L, 10L))
                .thenReturn(Optional.of(entity));

        LocalDate newDate = LocalDate.of(2024, 5, 10);

        userSpecService.updateGraduationDate(1L, 10L, newDate);

        assertEquals(newDate, entity.getGraduationDate());
        verify(userSpecRepository).save(entity);
    }

    // -----------------------------------------------------
    // DELETE SPECIALIZATION
    // -----------------------------------------------------
    @Test
    void deleteSpecialization_shouldCallRepository() {

        userSpecService.deleteSpecialization(1L, 10L);

        verify(userSpecRepository)
                .deleteByUser_UserIdAndSpecialization_SpecializationId(1L, 10L);
    }
}

