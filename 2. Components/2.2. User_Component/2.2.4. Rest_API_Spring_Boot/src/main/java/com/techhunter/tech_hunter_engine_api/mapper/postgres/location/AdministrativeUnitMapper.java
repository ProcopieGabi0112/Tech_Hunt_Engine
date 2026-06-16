package com.techhunter.tech_hunter_engine_api.mapper.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.AdministrativeUnitTypeEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.location.CountryEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AdministrativeUnitMapper {

    @Mapping(source = "type.administrativeUnitTypeId", target = "administrativeUnitTypeId")
    @Mapping(source = "type.name", target = "administrativeUnitTypeName")   // <-- AICI
    @Mapping(source = "country.countryId", target = "countryId")
    AdministrativeUnitDTO toDto(AdministrativeUnitEntity entity);

    @Mapping(target = "type", expression = "java(createType(dto.administrativeUnitTypeId()))")
    @Mapping(target = "country", expression = "java(createCountry(dto.countryId()))")
    AdministrativeUnitEntity toEntity(AdministrativeUnitDTO dto);

    default AdministrativeUnitTypeEntity createType(Long id) {
        if (id == null) return null;
        AdministrativeUnitTypeEntity t = new AdministrativeUnitTypeEntity();
        t.setAdministrativeUnitTypeId(id);
        return t;
    }

    default CountryEntity createCountry(Long id) {
        if (id == null) return null;
        CountryEntity c = new CountryEntity();
        c.setCountryId(id);
        return c;
    }
}