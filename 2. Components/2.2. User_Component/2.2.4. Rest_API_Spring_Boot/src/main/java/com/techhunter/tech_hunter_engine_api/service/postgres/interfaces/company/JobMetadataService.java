package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.JobMetadataResponseDTO;

public interface JobMetadataService {
    JobMetadataResponseDTO getAllMetadata();
}
