package com.techhunter.tech_hunter_engine_api.repository.postgres.user;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {

    Optional<UserEntity> findByEmail(String email);
    boolean existsByEmail(String email);
    List<UserEntity> findByDeletedFlag(String deletedFlag);
    Optional<UserEntity> findByResetToken(String resetToken);
    List<UserEntity> findByRole_RoleId(Long roleId);
}
