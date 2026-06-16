package com.techhunter.tech_hunter_engine_api.controller.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.IndustryTypeDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.IndustryTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/industry-types")
@RequiredArgsConstructor
public class IndustryTypeController {

    private final IndustryTypeService service;

    @GetMapping
    public List<IndustryTypeDTO> getAll() {
        return service.getAllIndustryTypes();
    }

    @GetMapping("/{id}")
    public IndustryTypeDTO getById(@PathVariable Long id) {
        return service.getIndustryTypeById(id);
    }
}
