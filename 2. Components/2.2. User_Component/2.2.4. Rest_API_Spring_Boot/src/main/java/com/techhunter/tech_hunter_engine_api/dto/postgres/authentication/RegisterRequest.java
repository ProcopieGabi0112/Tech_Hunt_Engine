package com.techhunter.tech_hunter_engine_api.dto.postgres.authentication;

import lombok.Data;

import java.time.LocalDate;

@Data
public class RegisterRequest {

    private String email;
    private String password;

    private String firstName;
    private String lastName;
    private LocalDate dateOfBirth;

    private String phone;
    private String gender;

    private Long roleId;
}
