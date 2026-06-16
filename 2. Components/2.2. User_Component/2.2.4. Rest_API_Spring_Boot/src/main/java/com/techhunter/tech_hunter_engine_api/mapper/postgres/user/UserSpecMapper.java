package com.techhunter.tech_hunter_engine_api.mapper.postgres.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserSpecEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserSpecMapper {

    @Mapping(source = "specialization.specializationId", target = "specializationId")
    @Mapping(source = "user.userId", target = "userId")
    UserSpecDTO toDto(UserSpecEntity entity);

    @Mapping(target = "specialization", expression = "java(createSpecialization(dto.specializationId()))")
    @Mapping(target = "user", expression = "java(createUser(dto.userId()))")
    UserSpecEntity toEntity(UserSpecDTO dto);

    default SpecializationEntity createSpecialization(Long id) {
        if (id == null) return null;
        SpecializationEntity s = new SpecializationEntity();
        s.setSpecializationId(id);
        return s;
    }

    default UserEntity createUser(Long id) {
        if (id == null) return null;
        UserEntity u = new UserEntity();
        u.setUserId(id);
        return u;
    }
}
