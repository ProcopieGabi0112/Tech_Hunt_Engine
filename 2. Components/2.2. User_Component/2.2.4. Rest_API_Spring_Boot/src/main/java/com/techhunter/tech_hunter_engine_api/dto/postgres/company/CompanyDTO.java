package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

import java.math.BigDecimal;
import java.time.LocalDate;

public record CompanyDTO(
        Long companyId,
        String legalEntityIdentifier,
        String name,
        String tradeRegisterNumber,
        String website,
        LocalDate foundationDate,
        Long noEmployees,
        String description,
        BigDecimal shareCapital,
        Long netProfit,
        Long averageAnnualRevenue,
        Long totalAssets,
        Long totalLiabilities,
        Long debtToEquityRatio,
        BigDecimal rating,
        Long industryTypeId,
        Long companyTypeId,
        Long companyLocationId,
        Long currencyCode
) {}
