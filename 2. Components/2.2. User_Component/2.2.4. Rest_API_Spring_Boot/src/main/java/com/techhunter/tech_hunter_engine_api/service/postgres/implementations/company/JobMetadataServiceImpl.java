package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.JobMetadataResponseDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.company.*;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.*;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.JobMetadataService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class JobMetadataServiceImpl implements JobMetadataService {

    private final DepartmentTypeRepository departmentTypeRepo;
    private final EmploymentTypeRepository employmentTypeRepo;
    private final WorkTypeRepository workTypeRepo;
    private final JobCategoryRepository jobCategoryRepo;
    private final JobTitleRepository jobTitleRepo;
    private final JobLevelRepository jobLevelRepo;

    private final DepartmentTypeMapper departmentTypeMapper;
    private final EmploymentTypeMapper employmentTypeMapper;
    private final WorkTypeMapper workTypeMapper;
    private final JobCategoryMapper jobCategoryMapper;
    private final JobTitleMapper jobTitleMapper;
    private final JobLevelMapper jobLevelMapper;

    @Override
    public JobMetadataResponseDTO getAllMetadata() {

        return new JobMetadataResponseDTO(
                departmentTypeRepo.findAll().stream().map(departmentTypeMapper::toDTO).toList(),
                employmentTypeRepo.findAll().stream().map(employmentTypeMapper::toDTO).toList(),
                workTypeRepo.findAll().stream().map(workTypeMapper::toDTO).toList(),
                jobCategoryRepo.findAll().stream().map(jobCategoryMapper::toDTO).toList(),
                jobTitleRepo.findAll().stream().map(jobTitleMapper::toDTO).toList(),
                jobLevelRepo.findAll().stream().map(jobLevelMapper::toDTO).toList()
        );
    }
}
