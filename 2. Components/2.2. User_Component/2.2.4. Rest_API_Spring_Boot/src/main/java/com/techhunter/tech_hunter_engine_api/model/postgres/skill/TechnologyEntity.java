package com.techhunter.tech_hunter_engine_api.model.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(name = "TECHNOLOGY TABLE", description = "Technologies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "technology", schema = "db_owner")
public class TechnologyEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "technology_code")
    private Long technologyCode;

    @Column(name = "name", length = 100)
    private String name;

    @Column(name = "release_date")
    private LocalDate releaseDate;

    @Column(name = "creator", length = 100)
    private String creator;

    @Column(name = "official_site", length = 255)
    private String officialSite;

    @Column(name = "rating", nullable = false, precision = 5, scale = 2)
    private BigDecimal rating = BigDecimal.ZERO;

    @Column(name = "description", length = 300)
    private String description;

    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Lob
    @Column(name = "sign_photo")
    private byte[] signPhoto;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "technology_type_code", nullable = false)
    private TechnologyTypeEntity technologyType;

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
