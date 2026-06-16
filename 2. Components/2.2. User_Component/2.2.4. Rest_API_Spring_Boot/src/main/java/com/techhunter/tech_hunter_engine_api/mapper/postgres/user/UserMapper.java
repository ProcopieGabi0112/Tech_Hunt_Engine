package com.techhunter.tech_hunter_engine_api.mapper.postgres.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    public UserDTO toDto(UserEntity entity) {
        if (entity == null) {
            return null;
        }

        return new UserDTO(
                entity.getUserId(),
                entity.getFirstName(),
                entity.getLastName()
        );
    }
}
