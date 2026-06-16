package com.techhunter.tech_hunter_engine_api.model.postgres.skill;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(name = "TECHNOLOGY_TYPE TABLE", description = "Technology types")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "technology_type", schema = "db_owner")
public class TechnologyTypeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "technology_type_code")
    private Long technologyTypeCode;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    @Column(name = "rating", nullable = false, precision = 5, scale = 2)
    private BigDecimal rating = BigDecimal.ZERO;

    @Column(name = "description", length = 300)
    private String description;

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