package com.techhunter.tech_hunter_engine_api.repository.postgres.company;

import com.techhunter.tech_hunter_engine_api.model.postgres.company.EmploymentTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmploymentTypeRepository extends JpaRepository<EmploymentTypeEntity, Long> {
}
