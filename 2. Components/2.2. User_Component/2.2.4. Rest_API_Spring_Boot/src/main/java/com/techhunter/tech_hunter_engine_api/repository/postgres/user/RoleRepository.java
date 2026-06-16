package com.techhunter.tech_hunter_engine_api.repository.postgres.user;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.RoleEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<RoleEntity,Long> {

    Optional<RoleEntity> findByName(String name);
}
