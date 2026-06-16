package com.techhunter.tech_hunter_engine_api.controller.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.dto.postgres.specialization.InstitutionDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.specialization.InstitutionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/institutions")
@RequiredArgsConstructor
public class InstitutionController {

    private final InstitutionService institutionService;

    @GetMapping
    public List<InstitutionDTO> getInstitutionsByLocation(@RequestParam Long locationId) {
        return institutionService.getInstitutionsByLocation(locationId);
    }
}