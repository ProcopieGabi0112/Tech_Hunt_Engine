package com.techhunter.tech_hunter_engine_api.mapper.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.LocationDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.CityEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.LocationEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface LocationMapper {

    @Mapping(source = "city.cityCode", target = "cityCode")
    LocationDTO toDto(LocationEntity entity);

    @Mapping(target = "city", expression = "java(createCity(dto.cityCode()))")
    LocationEntity toEntity(LocationDTO dto);

    default CityEntity createCity(Long id) {
        if (id == null) return null;
        CityEntity c = new CityEntity();
        c.setCityCode(id);
        return c;
    }
}