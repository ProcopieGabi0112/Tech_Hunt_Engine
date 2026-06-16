package com.techhunter.tech_hunter_engine_api.controller.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.OrganizationTypeDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.OrganizationTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/organization-types")
@RequiredArgsConstructor
public class OrganizationTypeController {

    private final OrganizationTypeService service;

    @GetMapping
    public List<OrganizationTypeDTO> getAll() {
        return service.getAllOrganizationTypes();
    }

    @GetMapping("/{id}")
    public OrganizationTypeDTO getById(@PathVariable Long id) {
        return service.getOrganizationTypeById(id);
    }
}
