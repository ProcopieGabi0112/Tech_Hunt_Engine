package com.techhunter.tech_hunter_engine_api.controller.postgres.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.SkillDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.SkillService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/skills")
public class SkillController {

    private final SkillService service;

    public SkillController(SkillService service) {
        this.service = service;
    }

    @GetMapping
    public List<SkillDTO> getByTechnology(@RequestParam Long technology) {
        return service.getByTechnology(technology);
    }

    @GetMapping(params = "version")
    public List<SkillDTO> getByVersion(@RequestParam Long version) {
        return service.getByVersion(version);
    }
}
