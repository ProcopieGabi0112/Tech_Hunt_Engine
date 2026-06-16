package com.techhunter.tech_hunter_engine_api.dto.postgres.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserSpecViewDTO {

    private Long specializationId;
    private String specializationName;
    private String institutionName;
    private String cityName;
    private String countryName;
    private LocalDate graduationDate;
}