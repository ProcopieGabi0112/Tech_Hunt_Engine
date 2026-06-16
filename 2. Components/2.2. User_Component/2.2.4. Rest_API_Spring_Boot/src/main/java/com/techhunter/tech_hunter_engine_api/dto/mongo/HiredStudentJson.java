package com.techhunter.tech_hunter_engine_api.dto.mongo;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public record HiredStudentJson(
        Long userId,
        String firstName,
        String lastName,
        String email,
        String phone,
        LocalDate birthDate,
        List<String> skills,
        List<String> certifications,
        List<String> specializations,
        LocalDateTime hiredAt,
        Long jobId,
        Long companyId
) {}
