package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.SkillDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.SkillMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.SkillRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.SkillService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SkillServiceImpl implements SkillService {

    private final SkillRepository repository;
    private final SkillMapper mapper;

    public SkillServiceImpl(SkillRepository repository,
                            SkillMapper mapper) {
        this.repository = repository;
        this.mapper = mapper;
    }

    @Override
    public List<SkillDTO> getByTechnology(Long technologyCode) {
        return repository.findByLastVersion_Technology_TechnologyCode(technologyCode)
                .stream()
                .map(mapper::toDto)
                .toList();
    }

    @Override
    public List<SkillDTO> getByVersion(Long versionCode) {
        return repository.findByLastVersion_VersionCode(versionCode)
                .stream()
                .map(mapper::toDto)
                .toList();
    }
}
