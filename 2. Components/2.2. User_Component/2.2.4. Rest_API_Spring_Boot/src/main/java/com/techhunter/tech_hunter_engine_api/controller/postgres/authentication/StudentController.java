package com.techhunter.tech_hunter_engine_api.controller.postgres.authentication;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "ADMIN ENDPOINTS", description = "Admin user type actions")
@RestController
@RequestMapping("/student")
public class StudentController {

    @PreAuthorize("hasRole('STUDENT')")
    @GetMapping("/dashboard")
    public String studentDashboard() {
        return "Student dashboard data";
    }

    @PreAuthorize("hasRole('STUDENT')")
    @GetMapping("/profile")
    public String studentProfile() {
        return "Student profile data";
    }
}