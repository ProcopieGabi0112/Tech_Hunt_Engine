package com.techhunter.tech_hunter_engine_api.controller.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.VersionDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.VersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/versions")
public class VersionController {

    private final VersionService service;

    public VersionController(VersionService service) {
        this.service = service;
    }

    @GetMapping
    public List<VersionDTO> getByTechnology(@RequestParam Long technology) {
        return service.getByTechnology(technology);
    }
}
