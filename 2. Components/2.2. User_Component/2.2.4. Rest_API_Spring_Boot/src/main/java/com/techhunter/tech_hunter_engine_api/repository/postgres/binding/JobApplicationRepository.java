package com.techhunter.tech_hunter_engine_api.repository.postgres.binding;

import com.techhunter.tech_hunter_engine_api.model.postgres.binding.JobApplicationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JobApplicationRepository extends JpaRepository<JobApplicationEntity, Long> {
}
