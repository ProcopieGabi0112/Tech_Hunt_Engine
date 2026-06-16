package com.techhunter.tech_hunter_engine_api.repository.postgres.user;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserSpecEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.UserSpecId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserSpecRepository extends JpaRepository<UserSpecEntity, UserSpecId> {

    List<UserSpecEntity> findByUser_UserId(Long userId);
    Optional<UserSpecEntity> findByUser_UserIdAndSpecialization_SpecializationId(Long userId, Long specializationId);
    void deleteByUser_UserIdAndSpecialization_SpecializationId(Long userId, Long specializationId);
}
