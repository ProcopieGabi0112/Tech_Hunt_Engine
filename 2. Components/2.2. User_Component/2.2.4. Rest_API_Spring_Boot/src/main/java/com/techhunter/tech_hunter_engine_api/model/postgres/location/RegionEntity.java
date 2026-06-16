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

@Schema(name = "REGION TABLE", description = "Contains world regions such as Eastern Europe, Western Europe, etc.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "region", schema = "db_owner")
public class RegionEntity {

    @Id
    @Column(name = "region_id")
    private Long regionId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 50)
    private String code;

    @Column(length = 200)
    private String description;
}
