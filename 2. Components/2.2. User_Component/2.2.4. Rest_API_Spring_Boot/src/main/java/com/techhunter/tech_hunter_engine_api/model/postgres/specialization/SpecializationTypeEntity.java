package com.techhunter.tech_hunter_engine_api.model.postgres.specialization;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Schema(name = "SPECIALIZATION TYPE TABLE", description = "Contains specialization categories.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "specialization_type", schema = "db_owner")
public class SpecializationTypeEntity {

    @Id
    @Column(name = "specialization_type_id")
    private Long specializationTypeId;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 200)
    private String description;
}
