package com.techhunter.tech_hunter_engine_api.controller.postgres.authentication;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "ADMIN ENDPOINTS", description = "Admin user type actions")
@RestController
@RequestMapping("/admin")
public class AdminController {

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/dashboard")
    public String adminDashboard() {
        return "Admin dashboard data";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/stats")
    public String adminStats() {
        return "Admin statistics";
    }
}