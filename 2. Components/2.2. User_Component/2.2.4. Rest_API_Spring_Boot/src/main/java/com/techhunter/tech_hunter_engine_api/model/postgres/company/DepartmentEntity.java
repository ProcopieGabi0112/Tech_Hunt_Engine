package com.techhunter.tech_hunter_engine_api.model.postgres.company;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "department", schema = "db_owner")
public class DepartmentEntity {

    @Id
    @Column(name = "department_id")
    private Long departmentId;

    @Column(nullable = false, length = 100)
    private String description;

    @Column(name = "annual_budget", nullable = false)
    private Long annualBudget;

    @Column(name = "operational_costs", nullable = false)
    private Long operationalCosts;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal expenses;

    @Column(name = "revenue_generated", nullable = false, precision = 15, scale = 2)
    private BigDecimal revenueGenerated;

    @Column(name = "no_employees", nullable = false)
    private Long noEmployees;

    @Column(name = "avg_salary", nullable = false, precision = 15, scale = 2)
    private BigDecimal avgSalary;

    @Column(name = "growth_potential", nullable = false, precision = 5, scale = 2)
    private BigDecimal growthPotential;

    @Column(name = "training_budget", nullable = false, precision = 15, scale = 2)
    private BigDecimal trainingBudget;

    @Column(name = "no_open_positions")
    private Long noOpenPositions;

    @Column(name = "turnover_rate", nullable = false, precision = 5, scale = 2)
    private BigDecimal turnoverRate;

    // STORED GENERATED COLUMN
    @Column(name = "rating", precision = 5, scale = 2, insertable = false, updatable = false)
    private BigDecimal rating;

    // ============================
    // FOREIGN KEYS
    // ============================

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "company_id", nullable = false)
    private CompanyEntity company;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "department_type_code", nullable = false)
    private DepartmentTypeEntity departmentType;

    // ============================
    // AUDIT FIELDS
    // ============================

    @Column(name = "creation_date", nullable = false)
    private LocalDateTime creationDate;

    @Column(name = "created_by", nullable = false, length = 50)
    private String createdBy;

    @Column(name = "last_update_date", nullable = false)
    private LocalDateTime lastUpdateDate;

    @Column(name = "last_updated_by", nullable = false, length = 50)
    private String lastUpdatedBy;

    // ============================
    // SYNC FIELDS
    // ============================

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
