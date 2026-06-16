package com.techhunter.tech_hunter_engine_api.model.postgres.location;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Schema(name = "ADMINISTRATIVE UNIT TABLE", description = "Contains counties, provinces, states.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "administrative_unit", schema = "db_owner")
public class AdministrativeUnitEntity {

    @Id
    @Column(name = "administrative_unit_id")
    private Long administrativeUnitId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 50)
    private String code;

    private Long population;
    private Long area;

    @Column(name = "no_cities")
    private Long numberOfCities;

    @Column(length = 200)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "administrative_unit_type_id")
    private AdministrativeUnitTypeEntity type;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "country_id")
    private CountryEntity country;
}
