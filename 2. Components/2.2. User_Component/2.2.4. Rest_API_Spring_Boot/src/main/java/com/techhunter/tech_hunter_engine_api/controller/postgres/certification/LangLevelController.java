package com.techhunter.tech_hunter_engine_api.controller.postgres.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LangLevelDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification.LangLevelService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/lang-levels")
@RequiredArgsConstructor
public class LangLevelController {

    private final LangLevelService langLevelService;

    @GetMapping
    public List<LangLevelDTO> getLevelsByLanguage(@RequestParam Long langCode) {
        return langLevelService.getLevelsByLanguage(langCode);
    }
}
