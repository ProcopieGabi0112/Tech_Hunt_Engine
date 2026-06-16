package com.techhunter.tech_hunter_engine_api.model.postgres.specialization;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Schema(name = "SPECIALIZATION TABLE", description = "Contains academic specializations offered by institutions.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "specialization", schema = "db_owner")
public class SpecializationEntity {

    @Id
    @Column(name = "specialization_id")
    private Long specializationId;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "degree_type", length = 50)
    private String degreeType;

    private BigDecimal employmentRate;
    private BigDecimal teachersFeedback;
    private BigDecimal coursesFeedback;
    private BigDecimal entryDifficulty;
    private BigDecimal graduationDifficulty;
    private BigDecimal industryReputation;
    private BigDecimal rating;

    @Column(length = 200)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "institution_id")
    private InstitutionEntity institution;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "specialization_type_id")
    private SpecializationTypeEntity specializationType;
}
