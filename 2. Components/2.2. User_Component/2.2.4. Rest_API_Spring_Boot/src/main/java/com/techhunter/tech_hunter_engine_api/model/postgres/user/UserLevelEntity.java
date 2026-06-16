package com.techhunter.tech_hunter_engine_api.model.postgres.user;

import com.techhunter.tech_hunter_engine_api.model.postgres.certification.LangLevelEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.certification.UserLevelId;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(
        name = "USER_LEVEL TABLE",
        description = "Associative table linking users with their language certifications"
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "user_level", schema = "db_owner")
public class UserLevelEntity {

    @EmbeddedId
    private UserLevelId id;

    // USER FK
    @ManyToOne(fetch = FetchType.EAGER)
    @MapsId("userId")
    @JoinColumn(name = "user_id", referencedColumnName = "user_id", nullable = false)
    private UserEntity user;

    // LANG_LEVEL FK
    @ManyToOne(fetch = FetchType.EAGER)
    @MapsId("langLevelId")
    @JoinColumn(name = "lang_level_id", referencedColumnName = "lang_level_id", nullable = false)
    private LangLevelEntity langLevel;

    @Column(name = "obtained_date", nullable = false)
    private LocalDate obtainedDate;

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
