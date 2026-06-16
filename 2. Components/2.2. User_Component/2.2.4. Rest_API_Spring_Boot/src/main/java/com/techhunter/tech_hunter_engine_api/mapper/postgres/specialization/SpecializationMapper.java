package com.techhunter.tech_hunter_engine_api.mapper.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.InstitutionEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationTypeEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface SpecializationMapper {

    @Mapping(source = "institution.institutionId", target = "institutionId")
    @Mapping(source = "specializationType.specializationTypeId", target = "specializationTypeId")
    SpecializationDTO toDto(SpecializationEntity entity);

    @Mapping(target = "institution", expression = "java(createInstitution(dto.institutionId()))")
    @Mapping(target = "specializationType", expression = "java(createType(dto.specializationTypeId()))")
    SpecializationEntity toEntity(SpecializationDTO dto);

    default InstitutionEntity createInstitution(Long id) {
        if (id == null) return null;
        InstitutionEntity i = new InstitutionEntity();
        i.setInstitutionId(id);
        return i;
    }

    default SpecializationTypeEntity createType(Long id) {
        if (id == null) return null;
        SpecializationTypeEntity t = new SpecializationTypeEntity();
        t.setSpecializationTypeId(id);
        return t;
    }
}