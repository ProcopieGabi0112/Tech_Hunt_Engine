package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.TechnologyMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.TechnologyRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.TechnologyService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TechnologyServiceImpl implements TechnologyService {

    private final TechnologyRepository repository;
    private final TechnologyMapper mapper;

    public TechnologyServiceImpl(TechnologyRepository repository,
                                 TechnologyMapper mapper) {
        this.repository = repository;
        this.mapper = mapper;
    }

    @Override
    public List<TechnologyDTO> getByType(Long typeCode) {
        return repository.findByTechnologyType_TechnologyTypeCode(typeCode)
                .stream()
                .map(mapper::toDto)
                .collect(Collectors.toList());
    }
}
