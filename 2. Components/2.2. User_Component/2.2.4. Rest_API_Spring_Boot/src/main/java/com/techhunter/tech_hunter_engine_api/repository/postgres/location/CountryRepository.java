package com.techhunter.tech_hunter_engine_api.repository.postgres.location;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.CountryEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CountryRepository extends JpaRepository<CountryEntity, Long> {

    List<CountryEntity> findByRegion_RegionId(Long regionId);
}
