package com.techhunter.tech_hunter_engine_api.model.postgres.location;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Schema(name = "ADMINISTRATIVE UNIT TYPE TABLE", description = "Contains types of administrative units (county, province, state).")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "administrative_unit_type", schema = "db_owner")
public class AdministrativeUnitTypeEntity {

    @Id
    @Column(name = "administrative_unit_type_id")
    private Long administrativeUnitTypeId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 200)
    private String description;
}
