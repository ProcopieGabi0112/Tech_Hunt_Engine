package com.techhunter.tech_hunter_engine_api.model.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(name = "USER_SKILL TABLE", description = "Associative table between user and skill")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "user_skill", schema = "db_owner")
@IdClass(UserSkillId.class)
public class UserSkillEntity {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @Id
    @Column(name = "skill_code")
    private Long skillCode;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "skill_code", insertable = false, updatable = false)
    private SkillEntity skill;

    @Column(name = "proficiency_level", nullable = false, precision = 5, scale = 2)
    private BigDecimal proficiencyLevel;

    @Column(name = "experience_months", nullable = false)
    private Integer experienceMonths;

    @Column(name = "last_used_date", nullable = false)
    private LocalDate lastUsedDate;

    @Column(name = "confidence_score", precision = 5, scale = 2)
    private BigDecimal confidenceScore;

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