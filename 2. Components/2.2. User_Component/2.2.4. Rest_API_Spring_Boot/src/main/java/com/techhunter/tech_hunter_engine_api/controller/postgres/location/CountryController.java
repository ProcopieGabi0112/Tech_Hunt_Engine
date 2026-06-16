package com.techhunter.tech_hunter_engine_api.controller.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.CountryDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.CountryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/countries")
@RequiredArgsConstructor
public class CountryController {

    private final CountryService countryService;

    @GetMapping
    public List<CountryDTO> getCountriesByRegion(@RequestParam Long regionId) {
        return countryService.getCountriesByRegion(regionId);
    }
}