package com.techhunter.tech_hunter_engine_api.model.postgres.location;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Schema(name = "LOCATION TABLE", description = "Contains street-level location details.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "location", schema = "db_owner")
public class LocationEntity {

    @Id
    @Column(name = "location_id")
    private Long locationId;

    @Column(name = "street_name", length = 100)
    private String streetName;

    @Column(name = "street_number", length = 20)
    private String streetNumber;

    @Column(name = "postal_code", length = 20)
    private String postalCode;

    private String building;
    private String staircase;
    private String floor;

    @Column(name = "appartment_number")
    private String apartmentNumber;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "city_code")
    private CityEntity city;
}
