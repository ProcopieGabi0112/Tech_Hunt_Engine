package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CompanyDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CreateCompanyDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.UpdateCompanyDTO;

public interface CompanyService {

    CompanyDTO createCompany(Long userId, String email, CreateCompanyDTO dto);

    CompanyDTO getMyCompany(Long userId);

    CompanyDTO updateCompany(Long userId, String email, UpdateCompanyDTO dto);

    void deleteCompany(Long userId, String email);
}