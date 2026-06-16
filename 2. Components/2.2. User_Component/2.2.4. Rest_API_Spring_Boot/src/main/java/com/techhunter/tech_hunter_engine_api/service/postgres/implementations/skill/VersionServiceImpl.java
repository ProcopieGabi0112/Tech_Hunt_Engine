package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.VersionDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.VersionMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.VersionRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.VersionService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VersionServiceImpl implements VersionService {

    private final VersionRepository repository;
    private final VersionMapper mapper;

    public VersionServiceImpl(VersionRepository repository, VersionMapper mapper) {
        this.repository = repository;
        this.mapper = mapper;
    }

    @Override
    public List<VersionDTO> getByTechnology(Long technologyCode) {
        return repository.findByTechnology_TechnologyCode(technologyCode)
                .stream()
                .map(mapper::toDto)
                .toList();
    }
}
