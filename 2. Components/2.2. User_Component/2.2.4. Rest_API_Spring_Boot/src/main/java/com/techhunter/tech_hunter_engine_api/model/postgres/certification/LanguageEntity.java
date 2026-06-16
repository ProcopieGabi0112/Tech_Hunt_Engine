package com.techhunter.tech_hunter_engine_api.model.postgres.certification;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(
        name = "LANGUAGE TABLE",
        description = "Stores all supported languages and their computed rating"
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "language", schema = "db_owner")
public class LanguageEntity {

    @Id
    @Column(name = "lang_code")
    private Long langCode;

    @Column(name = "name", nullable = false, length = 60)
    private String name;

    @Column(name = "iso_code", nullable = false, length = 5)
    private String isoCode;

    @Column(name = "no_native_speakers", nullable = false)
    private Long noNativeSpeakers;

    @Column(name = "no_speakers", nullable = false)
    private Long noSpeakers;

    @Column(name = "no_countries", nullable = false)
    private Integer noCountries;

    @Column(name = "no_companies", nullable = false)
    private Long noCompanies;

    // GENERATED ALWAYS AS (...) STORED
    @Column(
            name = "rating",
            insertable = false,
            updatable = false,
            precision = 5,
            scale = 2
    )
    private BigDecimal rating;

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
