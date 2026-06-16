package com.techhunter.tech_hunter_engine_api.repository.postgres.company;

import com.techhunter.tech_hunter_engine_api.model.postgres.company.CompanyEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CompanyRepository extends JpaRepository<CompanyEntity, Long> {

    boolean existsByUserId(Long userId);

    Optional<CompanyEntity> findByUserId(Long userId);
}
