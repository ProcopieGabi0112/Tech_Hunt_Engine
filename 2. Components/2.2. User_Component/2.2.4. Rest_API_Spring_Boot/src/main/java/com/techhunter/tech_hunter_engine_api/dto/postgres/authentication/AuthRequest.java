package com.techhunter.tech_hunter_engine_api.dto.postgres.authentication;

import lombok.Data;

@Data
public class AuthRequest {
    private String email;
    private String password;
}