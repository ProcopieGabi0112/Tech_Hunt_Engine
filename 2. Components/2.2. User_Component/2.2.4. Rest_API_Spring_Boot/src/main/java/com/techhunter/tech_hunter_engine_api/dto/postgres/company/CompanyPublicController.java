package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.CompanyPublicService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/companies")
@RequiredArgsConstructor
public class CompanyPublicController {

    private final CompanyPublicService service;

    // GET all companies (public)
    @GetMapping
    public List<CompanyPublicDTO> getAllCompanies() {
        return service.getAllPublicCompanies();
    }

    // GET company by ID (public)
    @GetMapping("/{id}")
    public CompanyPublicDTO getCompanyById(@PathVariable Long id) {
        return service.getPublicCompanyById(id);
    }

    // SEARCH companies by name
    @GetMapping("/search")
    public List<CompanyPublicDTO> searchCompanies(@RequestParam String name) {
        return service.searchCompaniesByName(name);
    }

    @GetMapping("/filter")
    public List<CompanyPublicDTO> filterCompanies(
            @RequestParam(required = false) Long countryId,
            @RequestParam(required = false) Long administrativeUnitTypeId,
            @RequestParam(required = false) Long administrativeUnitId,
            @RequestParam(required = false) Long cityId
    ) {
        return service.filterCompanies(countryId, administrativeUnitTypeId, administrativeUnitId, cityId);
    }
}
