package com.techhunter.tech_hunter_engine_api.repository.postgres.company;

import com.techhunter.tech_hunter_engine_api.model.postgres.company.IndustryTypeEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IndustryTypeRepository extends JpaRepository<IndustryTypeEntity, Long> {
}
