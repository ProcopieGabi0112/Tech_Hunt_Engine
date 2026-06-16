package com.techhunter.tech_hunter_engine_api.controller.postgres.location;

import com.techhunter.tech_hunter_engine_api.dto.postgres.location.RegionDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.location.RegionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/regions")
@RequiredArgsConstructor
public class RegionController {

    private final RegionService regionService;

    @GetMapping
    public List<RegionDTO> getRegions() {
        return regionService.getAllRegions();
    }
}