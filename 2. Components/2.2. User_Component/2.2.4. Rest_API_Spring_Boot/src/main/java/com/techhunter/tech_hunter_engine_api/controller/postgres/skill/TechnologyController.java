package com.techhunter.tech_hunter_engine_api.controller.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.TechnologyService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/technologies")
public class TechnologyController {

    private final TechnologyService service;

    public TechnologyController(TechnologyService service) {
        this.service = service;
    }

    @GetMapping
    public List<TechnologyDTO> getByType(@RequestParam Long type) {
        return service.getByType(type);
    }
}
