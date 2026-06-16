package com.techhunter.tech_hunter_engine_api.model.postgres.user;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(name = "UTILIZATORI TABLE",description = "The table containes the users from application")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "utilizatori", schema = "db_owner")
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "email", nullable = false, length = 70, unique = true)
    private String email;

    @Column(name = "first_name", nullable = false, length = 50)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;

    // GENERATED ALWAYS AS
    @Column(name = "user_name", insertable = false, updatable = false)
    private String userName;

    @Column(name = "app_email", insertable = false, updatable = false)
    private String appEmail;

    @Column(name = "password", nullable = false, length = 100)
    private String password;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "gender", length = 1)
    private String gender;

   @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "profile_image")
    private byte[] profileImage;

    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "profile_document")
    private byte[] profileDocument;

    @Column(name = "account_status", nullable = false, length = 20)
    private String accountStatus;

    @Column(name = "profile_approved_flag", nullable = false, length = 1)
    private String profileApprovedFlag;

    @Column(name = "report_sent_flag", nullable = false, length = 1)
    private String reportSentFlag;


    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "report_document")
    private byte[] reportDocument;

    @Column(name = "native_lang_code")
    private Long nativeLangCode;

    @Column(name = "supervizor_id")
    private Long supervizorId;

    @Column(name = "location_id")
    private Long locationId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", referencedColumnName = "role_id",nullable = false)
    private RoleEntity role;

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

    @Column(name = "reset_token")
    private String resetToken;

    @Column(name = "reset_token_expiry")
    private LocalDateTime resetTokenExpiry;
}