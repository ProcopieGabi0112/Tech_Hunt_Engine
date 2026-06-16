package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.certification;

import com.techhunter.tech_hunter_engine_api.dto.postgres.certification.LangLevelDTO;
import com.techhunter.tech_hunter_engine_api.repository.postgres.certification.LangLevelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LangLevelService {

    private final LangLevelRepository langLevelRepository;

    public List<LangLevelDTO> getLevelsByLanguage(Long langCode) {
        return langLevelRepository.findByLanguage_LangCode(langCode)
                .stream()
                .map(level -> new LangLevelDTO(
                        level.getLangLevelId(),
                        level.getName(),
                        level.getNivel(),
                        level.getRating(),
                        level.getValidityPeriod()
                ))
                .toList();
    }
}
