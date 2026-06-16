package com.techhunter.tech_hunter_engine_api.repository.postgres.location;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdministrativeUnitTypeRepository extends JpaRepository<AdministrativeUnitTypeEntity, Long> {
}
