package com.techhunter.tech_hunter_engine_api.dto.postgres.company;

import java.math.BigDecimal;

public record UpdateCompanyDTO(
        String website,
        String description,
        Long noEmployees,
        byte[] signImage,
        byte[] profileImage,
        BigDecimal shareCapital,
        Long netProfit,
        Long averageAnnualRevenue,
        Long totalAssets,
        Long totalLiabilities,
        Long debtToEquityRatio,
        Long industryTypeId,
        Long companyTypeId,
        Long companyLocationId,
        Long currencyCode
) {}
