package com.techhunter.tech_hunter_engine_api.mapper.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitTypeDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitTypeEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AdministrativeUnitTypeMapper {

    AdministrativeUnitTypeDTO toDto(AdministrativeUnitTypeEntity entity);

    AdministrativeUnitTypeEntity toEntity(AdministrativeUnitTypeDTO dto);
}