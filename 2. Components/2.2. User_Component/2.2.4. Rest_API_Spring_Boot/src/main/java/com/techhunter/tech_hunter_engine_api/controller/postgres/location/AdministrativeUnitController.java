package com.techhunter.tech_hunter_engine_api.controller.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.AdministrativeUnitDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.AdministrativeUnitService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/admin-units")
@RequiredArgsConstructor
public class AdministrativeUnitController {

    private final AdministrativeUnitService administrativeUnitService;

    @GetMapping
    public List<AdministrativeUnitDTO> getUnitsByCountry(@RequestParam Long countryId) {
        return administrativeUnitService.getUnitsByCountry(countryId);
    }
}