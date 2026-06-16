package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CompanyPublicDTO;

import java.util.List;

public interface CompanyPublicService {

    List<CompanyPublicDTO> getAllPublicCompanies();

    CompanyPublicDTO getPublicCompanyById(Long companyId);

    List<CompanyPublicDTO> searchCompaniesByName(String name);

    List<CompanyPublicDTO> filterCompanies(Long countryId,
                                           Long administrativeUnitTypeId,
                                           Long administrativeUnitId,
                                           Long cityId);
}
