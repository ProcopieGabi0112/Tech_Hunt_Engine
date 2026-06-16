package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecViewDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.user.UserSpecMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserSpecEntity;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.user.UserSpecViewMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.specialization.SpecializationRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserSpecRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user.UserSpecService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserSpecServiceImpl implements UserSpecService {

    private final UserSpecRepository userSpecRepository;
    private final UserRepository userRepository;
    private final SpecializationRepository specializationRepository;
    private final UserSpecViewMapper userSpecViewMapper;

    @Override
    public List<UserSpecDTO> getUserSpecializations(Long userId) {
        List<UserSpecEntity> entities = userSpecRepository.findByUser_UserId(userId);
        return entities.stream()
                .map(e -> new UserSpecDTO(
                        e.getSpecialization().getSpecializationId(),
                        e.getUser().getUserId(),
                        e.getGraduationDate()
                ))
                .toList();
    }

    @Override
    public void addUserSpecialization(UserSpecDTO dto) {
        UserEntity user = userRepository.findById(dto.userId())
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + dto.userId()));

        SpecializationEntity specialization = specializationRepository.findById(dto.specializationId())
                .orElseThrow(() -> new IllegalArgumentException("Specialization not found: " + dto.specializationId()));

        UserSpecEntity entity = new UserSpecEntity();
        entity.setUser(user);
        entity.setSpecialization(specialization);
        entity.setGraduationDate(dto.graduationDate());

        userSpecRepository.save(entity);
    }

    @Override
    public List<UserSpecViewDTO> getUserSpecializationsView(Long userId) {
        List<UserSpecEntity> entities = userSpecRepository.findByUser_UserId(userId);
        return entities.stream()
                .map(userSpecViewMapper::toDto)
                .toList();
    }

    @Override
    public void updateGraduationDate(Long userId, Long specializationId, LocalDate graduationDate) {
        UserSpecEntity entity = userSpecRepository
                .findByUser_UserIdAndSpecialization_SpecializationId(userId, specializationId)
                .orElseThrow(() -> new IllegalArgumentException("Specialization not found"));

        entity.setGraduationDate(graduationDate);
        userSpecRepository.save(entity);
    }
    @Override
    public void deleteSpecialization(Long userId, Long specializationId) {
        userSpecRepository.deleteByUser_UserIdAndSpecialization_SpecializationId(userId, specializationId);
    }
}