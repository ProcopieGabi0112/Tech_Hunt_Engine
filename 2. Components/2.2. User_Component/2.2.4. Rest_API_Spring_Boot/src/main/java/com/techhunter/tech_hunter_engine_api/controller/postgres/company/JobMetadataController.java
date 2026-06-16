package com.techhunter.tech_hunter_engine_api.controller.postgres.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.JobMetadataResponseDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.JobMetadataService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/job-metadata")
@RequiredArgsConstructor
public class JobMetadataController {

    private final JobMetadataService service;

    @GetMapping
    public JobMetadataResponseDTO getAllMetadata() {
        return service.getAllMetadata();
    }
}
