package com.techhunter.tech_hunter_engine_api.model.postgres.certification;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(
        name = "LANG_LEVEL TABLE",
        description = "Stores language certifications and proficiency levels"
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "lang_level", schema = "db_owner")
public class LangLevelEntity {

    @Id
    @Column(name = "lang_level_id")
    private Long langLevelId;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "nivel", nullable = false, length = 30)
    private String nivel;

    // FK către LANGUAGE
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "lang_code", referencedColumnName = "lang_code", nullable = false)
    private LanguageEntity language;

    @Column(name = "validity_period")
    private Integer validityPeriod;

    @Column(name = "rating", nullable = false, precision = 5, scale = 2)
    private BigDecimal rating;

    @Column(name = "description", length = 250)
    private String description;

    // TECHNICAL COLUMNS
    @Column(name = "creation_date", nullable = false, insertable = false, updatable = false)
    private LocalDateTime creationDate;

    @Column(name = "created_by", nullable = false, length = 50)
    private String createdBy;

    @Column(name = "last_update_date", nullable = false, insertable = false, updatable = false)
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
