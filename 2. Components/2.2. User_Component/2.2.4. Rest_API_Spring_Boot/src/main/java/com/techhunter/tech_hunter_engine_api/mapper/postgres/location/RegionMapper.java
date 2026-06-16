package com.techhunter.tech_hunter_engine_api.mapper.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.RegionDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.RegionEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface RegionMapper {

    RegionDTO toDto(RegionEntity entity);

    RegionEntity toEntity(RegionDTO dto);
}