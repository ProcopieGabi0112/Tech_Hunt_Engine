package com.techhunter.tech_hunter_engine_api.repository.postgres.location;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AdministrativeUnitRepository extends JpaRepository<AdministrativeUnitEntity, Long> {

    List<AdministrativeUnitEntity> findByCountry_CountryId(Long countryId);
}
