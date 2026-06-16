package com.techhunter.tech_hunter_engine_api.controller.postgres.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LanguageDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification.LanguageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/languages")
@RequiredArgsConstructor
public class LanguageController {

    private final LanguageService languageService;

    @GetMapping
    public List<LanguageDTO> getLanguages() {
        return languageService.getAllLanguages();
    }
}
