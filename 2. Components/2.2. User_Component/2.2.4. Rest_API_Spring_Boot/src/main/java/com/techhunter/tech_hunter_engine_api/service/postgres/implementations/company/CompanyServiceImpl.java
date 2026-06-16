package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.company;

import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CompanyDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.CreateCompanyDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.company.UpdateCompanyDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.CompanyEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.CompanyRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.company.CompanyService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CompanyServiceImpl implements CompanyService {

    private final CompanyRepository repo;

    @Override
    public CompanyDTO createCompany(Long userId, String email, CreateCompanyDTO dto) {

        if (repo.existsByUserId(userId)) {
            throw new IllegalStateException("User already has a company");
        }

        CompanyEntity entity = new CompanyEntity();
        entity.setLegalEntityIdentifier(dto.legalEntityIdentifier());
        entity.setName(dto.name());
        entity.setTradeRegisterNumber(dto.tradeRegisterNumber());
        entity.setWebsite(dto.website());
        entity.setFoundationDate(dto.foundationDate());
        entity.setNoEmployees(dto.noEmployees());
        entity.setDescription(dto.description());
        entity.setSignImage(dto.signImage());
        entity.setProfileImage(dto.profileImage());
        entity.setShareCapital(dto.shareCapital());
        entity.setNetProfit(dto.netProfit());
        entity.setAverageAnnualRevenue(dto.averageAnnualRevenue());
        entity.setTotalAssets(dto.totalAssets());
        entity.setTotalLiabilities(dto.totalLiabilities());
        entity.setDebtToEquityRatio(dto.debtToEquityRatio());
        entity.setIndustryTypeId(dto.industryTypeId());
        entity.setCompanyTypeId(dto.companyTypeId());
        entity.setCompanyLocationId(dto.companyLocationId());
        entity.setCurrencyCode(dto.currencyCode());

        entity.setUserId(userId);
        entity.setUserEmail(email);

        // technical columns handled by trigger
        entity.setSourceSystem("pg_env");
        entity.setSyncStatus("synced");
        entity.setSyncVersion(1L);
        entity.setDeletedFlag("N");

        CompanyEntity saved = repo.save(entity);

        return mapToDTO(saved);
    }

    @Override
    public CompanyDTO getMyCompany(Long userId) {
        return repo.findByUserId(userId)
                .map(this::mapToDTO)
                .orElse(null);
    }

    private CompanyDTO mapToDTO(CompanyEntity c) {
        return new CompanyDTO(
                c.getCompanyId(),
                c.getLegalEntityIdentifier(),
                c.getName(),
                c.getTradeRegisterNumber(),
                c.getWebsite(),
                c.getFoundationDate(),
                c.getNoEmployees(),
                c.getDescription(),
                c.getShareCapital(),
                c.getNetProfit(),
                c.getAverageAnnualRevenue(),
                c.getTotalAssets(),
                c.getTotalLiabilities(),
                c.getDebtToEquityRatio(),
                c.getRating(),
                c.getIndustryTypeId(),
                c.getCompanyTypeId(),
                c.getCompanyLocationId(),
                c.getCurrencyCode()
        );
    }

    @Override
    public CompanyDTO updateCompany(Long userId, String email, UpdateCompanyDTO dto) {

        CompanyEntity entity = repo.findByUserId(userId)
                .orElseThrow(() -> new IllegalStateException("User has no company"));

        entity.setWebsite(dto.website());
        entity.setDescription(dto.description());
        entity.setNoEmployees(dto.noEmployees());
        entity.setSignImage(dto.signImage());
        entity.setProfileImage(dto.profileImage());
        entity.setShareCapital(dto.shareCapital());
        entity.setNetProfit(dto.netProfit());
        entity.setAverageAnnualRevenue(dto.averageAnnualRevenue());
        entity.setTotalAssets(dto.totalAssets());
        entity.setTotalLiabilities(dto.totalLiabilities());
        entity.setDebtToEquityRatio(dto.debtToEquityRatio());
        entity.setIndustryTypeId(dto.industryTypeId());
        entity.setCompanyTypeId(dto.companyTypeId());
        entity.setCompanyLocationId(dto.companyLocationId());
        entity.setCurrencyCode(dto.currencyCode());

        entity.setLastUpdatedBy(email);

        CompanyEntity saved = repo.save(entity);
        return mapToDTO(saved);
    }

    @Override
    public void deleteCompany(Long userId, String email) {
        CompanyEntity entity = repo.findByUserId(userId)
                .orElseThrow(() -> new IllegalStateException("User has no company"));

        entity.setDeletedFlag("Y");
        entity.setLastUpdatedBy(email);

        repo.save(entity);
    }
}
