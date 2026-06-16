package com.techhunter.tech_hunter_engine_api.mapper.postgres.user;


import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecViewDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserSpecEntity;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface UserSpecViewMapper {

    @Mapping(source = "specialization.specializationId", target = "specializationId")
    @Mapping(source = "specialization.name", target = "specializationName")
    @Mapping(target = "institutionName", ignore = true)
    @Mapping(target = "cityName", ignore = true)
    @Mapping(target = "countryName", ignore = true)
    @Mapping(source = "graduationDate", target = "graduationDate")
    UserSpecViewDTO toDto(UserSpecEntity entity);

    @AfterMapping
    default void fillNestedFields(UserSpecEntity e, @MappingTarget UserSpecViewDTO dto) {

        var spec = e.getSpecialization();
        if (spec == null) return;

        var inst = spec.getInstitution();
        if (inst != null) {
            dto.setInstitutionName(inst.getName());

            var loc = inst.getLocation();
            if (loc != null && loc.getCity() != null) {
                var city = loc.getCity();
                dto.setCityName(city.getName());

                var admin = city.getAdministrativeUnit();
                if (admin != null && admin.getCountry() != null) {
                    dto.setCountryName(admin.getCountry().getName());
                }
            }
        }
    }
}