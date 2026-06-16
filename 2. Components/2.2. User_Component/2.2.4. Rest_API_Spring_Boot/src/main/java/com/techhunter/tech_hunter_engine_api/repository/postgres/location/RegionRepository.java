package com.techhunter.tech_hunter_engine_api.repository.postgres.location;


import com.techhunter.tech_hunter_engine_api.model.postgres.location.RegionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RegionRepository extends JpaRepository<RegionEntity, Long> {
}
