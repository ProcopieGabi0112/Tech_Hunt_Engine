package com.techhunter.tech_hunter_engine_api.model.postgres.specialization;

import com.techhunter.tech_hunter_engine_api.model.postgres.location.LocationEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Schema(name = "INSTITUTION TABLE", description = "Contains universities, colleges, academies.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "institution", schema = "db_owner")
public class InstitutionEntity {

    @Id
    @Column(name = "institution_id")
    private Long institutionId;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 2000)
    private String website;

    @Column(name = "founding_year", length = 4)
    private String foundingYear;

    private BigDecimal rating;

    @Lob
    @Column(name = "profile_picture")
    private byte[] profilePicture;

    @Column(length = 250)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "location_id")
    private LocationEntity location;
}
