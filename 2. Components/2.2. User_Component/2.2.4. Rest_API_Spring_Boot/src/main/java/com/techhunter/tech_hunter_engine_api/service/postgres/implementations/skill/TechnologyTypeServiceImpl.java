package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.skill;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.TechnologyTypeDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.skill.TechnologyTypeMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.skill.TechnologyTypeRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.TechnologyTypeService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TechnologyTypeServiceImpl implements TechnologyTypeService {

    private final TechnologyTypeRepository repository;
    private final TechnologyTypeMapper mapper;

    public TechnologyTypeServiceImpl(TechnologyTypeRepository repository,
                                     TechnologyTypeMapper mapper) {
        this.repository = repository;
        this.mapper = mapper;
    }

    @Override
    public List<TechnologyTypeDTO> getAllTypes() {
        return repository.findAll()
                .stream()
                .map(mapper::toDto)
                .collect(Collectors.toList());
    }
}
