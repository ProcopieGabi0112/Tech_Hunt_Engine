package com.techhunter.tech_hunter_engine_api.repository.postgres.location;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.LocationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LocationRepository extends JpaRepository<LocationEntity, Long> {

    List<LocationEntity> findByCity_CityCode(Long cityCode);
}
