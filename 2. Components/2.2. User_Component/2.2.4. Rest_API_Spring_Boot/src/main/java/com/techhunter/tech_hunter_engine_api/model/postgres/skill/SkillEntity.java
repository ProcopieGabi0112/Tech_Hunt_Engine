package com.techhunter.tech_hunter_engine_api.model.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(name = "SKILL TABLE", description = "Skills")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "skill", schema = "db_owner")
public class SkillEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "skill_code")
    private Long skillCode;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "prerequisite_knowledge", nullable = false, precision = 5, scale = 2)
    private BigDecimal prerequisiteKnowledge;

    @Column(name = "learning_difficulty", nullable = false, precision = 5, scale = 2)
    private BigDecimal learningDifficulty;

    @Column(name = "implementation_difficulty", nullable = false, precision = 5, scale = 2)
    private BigDecimal implementationDifficulty;

    @Column(name = "cross_platform_applicability", nullable = false, precision = 5, scale = 2)
    private BigDecimal crossPlatformApplicability;

    // rating generated in DB
    @Column(name = "rating", precision = 5, scale = 2, insertable = false, updatable = false)
    private BigDecimal rating;

    @Column(name = "description", length = 200)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "last_version_code", nullable = false)
    private VersionEntity lastVersion;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "first_version_code")
    private VersionEntity firstVersion;

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