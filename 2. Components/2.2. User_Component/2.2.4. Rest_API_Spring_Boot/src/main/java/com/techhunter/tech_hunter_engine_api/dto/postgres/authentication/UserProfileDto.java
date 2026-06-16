package com.techhunter.tech_hunter_engine_api.dto.postgres.authentication;

import java.time.LocalDate;

public record UserProfileDto(
        Long userId,
        String email,
        String firstName,
        String lastName,
        String roleName,
        String phone,
        String gender,
        LocalDate dateOfBirth,
        Long nativeLangCode,
        Long locationId,
        Long supervizorId,
        String profileApprovedFlag
) {}