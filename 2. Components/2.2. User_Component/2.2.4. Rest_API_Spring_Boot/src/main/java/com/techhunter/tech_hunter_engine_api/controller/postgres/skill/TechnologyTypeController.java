package com.techhunter.tech_hunter_engine_api.controller.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyTypeDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.TechnologyTypeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/technology-types")
public class TechnologyTypeController {

    private final TechnologyTypeService service;

    public TechnologyTypeController(TechnologyTypeService service) {
        this.service = service;
    }

    @GetMapping
    public List<TechnologyTypeDTO> getAllTypes() {
        return service.getAllTypes();
    }
}