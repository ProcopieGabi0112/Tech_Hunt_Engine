package com.techhunter.tech_hunter_engine_api.dto.postgres.authentication;

import lombok.Data;

@Data
public class ResetPasswordRequest {
    private String token;
    private String newPassword;
}