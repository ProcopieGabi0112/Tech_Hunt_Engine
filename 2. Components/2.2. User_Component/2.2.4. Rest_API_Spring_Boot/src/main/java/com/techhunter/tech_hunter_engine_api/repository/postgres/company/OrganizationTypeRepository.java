package com.techhunter.tech_hunter_engine_api.repository.postgres.company;

import com.techhunter.tech_hunter_engine_api.model.postgres.company.OrganizationTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationTypeRepository extends JpaRepository<OrganizationTypeEntity, Long> {
}
