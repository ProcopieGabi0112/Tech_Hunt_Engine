package com.techhunter.tech_hunter_engine_api.controller.postgres.authentication;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "SPECIALIST_HR ENDPOINTS", description = "Specialist_HR user type actions")
@RestController
@RequestMapping("/hr")
public class HrController {

    @PreAuthorize("hasRole('SPECIALIST_HR')")
    @GetMapping("/dashboard")
    public String hrDashboard() {
        return "HR dashboard data";
    }

    @PreAuthorize("hasRole('SPECIALIST_HR')")
    @GetMapping("/candidates")
    public String hrCandidates() {
        return "HR candidates list";
    }
}