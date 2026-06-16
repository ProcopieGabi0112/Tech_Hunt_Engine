package com.techhunter.tech_hunter_engine_api.controller.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.SpecializationDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization.SpecializationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/specializations")
@RequiredArgsConstructor
public class SpecializationController {

    private final SpecializationService specializationService;

    @GetMapping
    public List<SpecializationDTO> getSpecializationsByInstitution(@RequestParam Long institutionId) {
        return specializationService.getSpecializationsByInstitution(institutionId);
    }
}