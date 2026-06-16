package com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.InstitutionDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.LocationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.InstitutionEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface InstitutionMapper {

    @Mapping(source = "location.locationId", target = "locationId")
    InstitutionDTO toDto(InstitutionEntity entity);

    @Mapping(target = "location", expression = "java(createLocation(dto.locationId()))")
    InstitutionEntity toEntity(InstitutionDTO dto);

    default LocationEntity createLocation(Long id) {
        if (id == null) return null;
        LocationEntity l = new LocationEntity();
        l.setLocationId(id);
        return l;
    }
}