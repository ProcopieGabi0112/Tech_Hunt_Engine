package com.techhunter.tech_hunter_engine_api.model.postgres.location;

import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LanguageEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.CurrencyEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Schema(name = "COUNTRY TABLE", description = "Contains countries and their economic indicators.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "country", schema = "db_owner")
public class CountryEntity {

    @Id
    @Column(name = "country_id")
    private Long countryId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 30)
    private String code;

    private Long population;
    private Long area;

    @Column(name = "time_zone", length = 50)
    private String timeZone;

    @Column(name = "unemployment_rate")
    private BigDecimal unemploymentRate;

    @Column(name = "inflation_rate")
    private BigDecimal inflationRate;

    @Column(name = "average_monthly_salary")
    private BigDecimal averageMonthlySalary;

    @Column(name = "corporate_tax_rate")
    private BigDecimal corporateTaxRate;

    private BigDecimal rating;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "region_id")
    private RegionEntity region;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "official_lang_code")
    private LanguageEntity language;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "currency_code")
    private CurrencyEntity currency;
}

