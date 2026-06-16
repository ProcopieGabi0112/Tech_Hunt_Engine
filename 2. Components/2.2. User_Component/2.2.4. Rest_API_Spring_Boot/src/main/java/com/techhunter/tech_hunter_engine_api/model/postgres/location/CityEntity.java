package com.techhunter.tech_hunter_engine_api.model.postgres.location;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Schema(name = "CITY TABLE", description = "Contains cities belonging to administrative units.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "city", schema = "db_owner")
public class CityEntity {

    @Id
    @Column(name = "city_code")
    private Long cityCode;

    @Column(nullable = false, length = 100)
    private String name;

    private Long population;
    private Long area;

    @Column(name = "is_capital", length = 1)
    private String isCapital;

    private BigDecimal latitude;
    private BigDecimal longitude;

    @Column(length = 200)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "administrative_unit_id")
    private AdministrativeUnitEntity administrativeUnit;
}
