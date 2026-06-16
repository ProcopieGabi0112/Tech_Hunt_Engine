package com.techhunter.tech_hunter_engine_api.model.postgres.user;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import java.time.LocalDateTime;

import lombok.*;

@Schema(name = "ROLE TABLE",description = "The table that contains the users role from application")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "role",schema = "db_owner")
public class RoleEntity {

    @Id
    @Column(name= "role_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private  Long roleId;

    @Column(name = "name",nullable = false,length = 50)
    private String name;

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

    @Column(name = "deleted_flag", nullable = false)
    private String deletedFlag;

    // getters & setters (sau @Data de la Lombok, dacă îl folosești)

}
