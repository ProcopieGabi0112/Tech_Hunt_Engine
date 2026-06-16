package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.binding;

import com.techhunter.tech_hunter_engine_api.dto.postgres.binding.JobApplicationDTO;

public interface JobApplicationService {

    JobApplicationDTO updateStatus(Long applicationId, String newStatus);

    JobApplicationDTO getById(Long applicationId);

    JobApplicationDTO applyToJob(Long userId, Long jobId, String salary, String source);
}