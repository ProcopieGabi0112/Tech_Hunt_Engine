package com.techhunter.tech_hunter_engine_api.dto.postgres.user;

public record UserDTO(
        Long userId,
        String firstName,
        String lastName
) {}
