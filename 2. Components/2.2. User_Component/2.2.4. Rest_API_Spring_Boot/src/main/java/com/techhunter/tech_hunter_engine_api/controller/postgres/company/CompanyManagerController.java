package com.techhunter.tech_hunter_engine_api.controller.postgres.company;

import com.techhunter.tech_hunter_engine_api.config.security.SecurityUtils;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CompanyDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CreateCompanyDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.UpdateCompanyDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.CompanyService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/manager/company")
@RequiredArgsConstructor
public class CompanyManagerController {

    private final CompanyService companyService;

    private Long getUserId() {
        return SecurityUtils.getCurrentUserIdFromContext();
    }

    private String getUserEmail() {
        return SecurityUtils.getCurrentUserEmailFromContext();
    }

    // -----------------------------
    // CREATE COMPANY (manager only)
    // -----------------------------
    @PostMapping
    public CompanyDTO createCompany(@RequestBody CreateCompanyDTO dto) {
        return companyService.createCompany(getUserId(), getUserEmail(), dto);
    }

    // -----------------------------
    // GET MY COMPANY
    // -----------------------------
    @GetMapping
    public CompanyDTO getMyCompany() {
        return companyService.getMyCompany(getUserId());
    }

    // -----------------------------
    // UPDATE MY COMPANY
    // -----------------------------
    @PutMapping
    public CompanyDTO updateMyCompany(@RequestBody UpdateCompanyDTO dto) {
        return companyService.updateCompany(getUserId(), getUserEmail(), dto);
    }

    // -----------------------------
    // DELETE MY COMPANY (soft delete)
    // -----------------------------
    @DeleteMapping
    public void deleteMyCompany() {
        companyService.deleteCompany(getUserId(), getUserEmail());
    }
}
