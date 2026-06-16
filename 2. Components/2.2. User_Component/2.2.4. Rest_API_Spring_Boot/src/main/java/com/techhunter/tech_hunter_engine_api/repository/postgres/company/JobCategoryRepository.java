package com.techhunter.tech_hunter_engine_api.repository.postgres.company;

import com.techhunter.tech_hunter_engine_api.model.postgres.company.JobCategoryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JobCategoryRepository extends JpaRepository<JobCategoryEntity, Long> {
}
