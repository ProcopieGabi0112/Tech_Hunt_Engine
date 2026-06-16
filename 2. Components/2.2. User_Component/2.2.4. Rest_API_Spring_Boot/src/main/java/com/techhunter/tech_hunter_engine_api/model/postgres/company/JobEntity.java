package com.techhunter.tech_hunter_engine_api.model.postgres.company;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.LocationEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "job", schema = "db_owner")
public class JobEntity {

    @Id
    @Column(name = "job_id")
    private Long jobId;

    @Column(nullable = false, length = 200)
    private String description;

    @Column(nullable = false, length = 500)
    private String requirements;

    @Column(nullable = false, length = 300)
    private String responsabilities;

    @Column(length = 300)
    private String benefits;

    @Column(name = "salary_min", nullable = false)
    private Long salaryMin;

    @Column(name = "salary_max")
    private Long salaryMax;

    @Column(name = "hire_date", nullable = false)
    private LocalDate hireDate;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Column(name = "employment_period")
    private Long employmentPeriod;

    @Column(name = "demand_score", nullable = false)
    private BigDecimal demandScore;

    @Column(name = "complexity_score", nullable = false)
    private BigDecimal complexityScore;

    @Column(name = "employees_rating", nullable = false)
    private BigDecimal employeesRating;

    @Column(name = "job_status", nullable = false, length = 50)
    private String jobStatus;

    // ============================
    // FOREIGN KEYS
    // ============================

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "department_id")
    private DepartmentEntity department;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "employment_type_id")
    private EmploymentTypeEntity employmentType;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "work_type_id")
    private WorkTypeEntity workType;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "job_title_id")
    private JobTitleEntity jobTitle;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "job_level_id")
    private JobLevelEntity jobLevel;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "job_category_id")
    private JobCategoryEntity jobCategory;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "currency_code")
    private CurrencyEntity currency;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "location_id")
    private LocationEntity location;

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