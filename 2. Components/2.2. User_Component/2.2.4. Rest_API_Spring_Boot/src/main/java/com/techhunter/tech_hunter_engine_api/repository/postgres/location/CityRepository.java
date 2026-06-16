package com.techhunter.tech_hunter_engine_api.repository.postgres.location;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.CityEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CityRepository extends JpaRepository<CityEntity, Long> {

    List<CityEntity> findByAdministrativeUnit_AdministrativeUnitId(Long administrativeUnitId);
}
