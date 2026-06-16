package com.techhunter.tech_hunter_engine_api.controller.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.LocationDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.LocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/locations")
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;

    @GetMapping
    public List<LocationDTO> getLocationsByCity(@RequestParam Long cityCode) {
        return locationService.getLocationsByCity(cityCode);
    }
}