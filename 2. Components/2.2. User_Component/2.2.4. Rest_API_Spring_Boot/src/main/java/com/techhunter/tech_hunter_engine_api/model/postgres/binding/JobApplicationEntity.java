package com.techhunter.tech_hunter_engine_api.model.postgres.binding;

import com.techhunter.tech_hunter_engine_api.model.postgres.company.JobEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "job_application", schema = "db_owner")
public class JobApplicationEntity {

    @Id
    @Column(name = "application_id")
    private Long applicationId;

    @Column(name = "apply_date", nullable = false)
    private LocalDate applyDate;

    @Column(name = "apply_source", nullable = false, length = 50)
    private String applySource;

    @Column(nullable = false, length = 50)
    private String status;

    @Column(nullable = false, length = 50)
    private String salary;

    // FOREIGN KEYS
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private UserEntity user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "job_id")
    private JobEntity job;

    // AUDIT FIELDS
    @Column(name = "creation_date", nullable = false)
    private LocalDateTime creationDate;

    @Column(name = "created_by", nullable = false, length = 50)
    private String createdBy;

    @Column(name = "last_update_date", nullable = false)
    private LocalDateTime lastUpdateDate;

    @Column(name = "last_updated_by", nullable = false, length = 50)
    private String lastUpdatedBy;

    // SYNC FIELDS
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
