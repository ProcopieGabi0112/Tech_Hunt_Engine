package com.techhunter.tech_hunter_engine_api.controller.postgres.authentication;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "MANAGER ENDPOINTS", description = "Manager user type actions")
@RestController
@RequestMapping("/manager")
public class ManagerController {

    @PreAuthorize("hasRole('MANAGER')")
    @GetMapping("/dashboard")
    public String managerDashboard() {
        return "Manager dashboard data";
    }

    @PreAuthorize("hasRole('MANAGER')")
    @GetMapping("/team")
    public String managerTeam() {
        return "Manager team data";
    }
}