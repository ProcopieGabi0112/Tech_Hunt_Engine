package com.techhunter.tech_hunter_engine_api.model.postgres.company;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(name = "COMPANY TABLE", description = "Stores company information created by managers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "company", schema = "db_owner")
public class CompanyEntity {

    @Id
    @Column(name = "company_id")
    private Long companyId; // handled by trigger

    @Column(name = "legal_entity_identifier", nullable = false, length = 50)
    private String legalEntityIdentifier;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "trade_register_number", nullable = false, length = 50)
    private String tradeRegisterNumber;

    @Column(name = "website", nullable = false, length = 255)
    private String website;

    @Column(name = "foundation_date", nullable = false)
    private LocalDate foundationDate;

    @Column(name = "no_employees", nullable = false)
    private Long noEmployees;

    @Column(name = "description", nullable = false, length = 200)
    private String description;

    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "sign_image")
    private byte[] signImage;

    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "profile_image")
    private byte[] profileImage;

    @Column(name = "share_capital", nullable = false, precision = 15, scale = 2)
    private BigDecimal shareCapital;

    @Column(name = "net_profit", nullable = false)
    private Long netProfit;

    @Column(name = "average_annual_revenue", nullable = false)
    private Long averageAnnualRevenue;

    @Column(name = "total_assets", nullable = false)
    private Long totalAssets;

    @Column(name = "total_liabilities", nullable = false)
    private Long totalLiabilities;

    @Column(name = "debt_to_equity_ratio", nullable = false)
    private Long debtToEquityRatio;

    @Column(name = "rating", insertable = false, updatable = false)
    private BigDecimal rating;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "user_email", nullable = false, length = 70)
    private String userEmail;

    @Column(name = "industry_type_id", nullable = false)
    private Long industryTypeId;

    @Column(name = "company_type_id", nullable = false)
    private Long companyTypeId;

    @Column(name = "company_location_id", nullable = false)
    private Long companyLocationId;

    @Column(name = "currency_code", nullable = false)
    private Long currencyCode;

    // TECHNICAL COLUMNS
    @Column(name = "creation_date", nullable = false)
    private LocalDateTime creationDate;

    @Column(name = "created_by", nullable = false, length = 50)
    private String createdBy;

    @Column(name = "last_update_date", nullable = false)
    private LocalDateTime lastUpdateDate;

    @Column(name = "last_updated_by", nullable = false, length = 50)
    private String lastUpdatedBy;

    @Column(name = "source_system", nullable = false, length = 20)
    private String sourceSystem;

    @Column(name = "sync_status", nullable = false, length = 20)
    private String syncStatus;

    @Column(name = "sync_version", nullable = false)
    private Long syncVersion;

    @Column(name = "last_synced_at", nullable = false)
    private LocalDateTime lastSyncedAt;

    @Column(name = "deleted_flag", nullable = false, length = 1)
    private String deletedFlag;
}