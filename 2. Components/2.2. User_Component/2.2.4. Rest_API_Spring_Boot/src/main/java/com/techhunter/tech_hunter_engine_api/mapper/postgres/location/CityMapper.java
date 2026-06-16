package com.techhunter.tech_hunter_engine_api.mapper.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CityDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.CityEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CityMapper {

    @Mapping(source = "administrativeUnit.administrativeUnitId", target = "administrativeUnitId")
    CityDTO toDto(CityEntity entity);

    @Mapping(target = "administrativeUnit", expression = "java(createAdminUnit(dto.administrativeUnitId()))")
    CityEntity toEntity(CityDTO dto);

    default AdministrativeUnitEntity createAdminUnit(Long id) {
        if (id == null) return null;
        AdministrativeUnitEntity a = new AdministrativeUnitEntity();
        a.setAdministrativeUnitId(id);
        return a;
    }
}
