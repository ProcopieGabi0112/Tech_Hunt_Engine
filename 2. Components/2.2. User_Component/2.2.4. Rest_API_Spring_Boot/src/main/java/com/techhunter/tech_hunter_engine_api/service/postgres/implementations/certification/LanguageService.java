package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LanguageDTO;
import com.techhunter.tech_hunter_engine_api.repository.postgres.certification.LanguageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LanguageService {

    private final LanguageRepository languageRepository;

    public List<LanguageDTO> getAllLanguages() {
        return languageRepository.findAll()
                .stream()
                .map(lang -> new LanguageDTO(
                        lang.getLangCode(),
                        lang.getName(),
                        lang.getIsoCode(),
                        lang.getRating()
                ))
                .toList();
    }
}