package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Schema(name = "AddUserSkillDTO", description = "Payload pentru adăugarea unei competențe tehnice la utilizator")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddUserSkillDTO {

    @Schema(description = "Codul skill-ului (PK din tabela skill)", required = true, example = "123")
    @NotNull
    private Long skillCode;

    @Schema(description = "Nivel de proficiency (0.00 - 100.00)", required = true, example = "75.50")
    @NotNull
    @DecimalMin(value = "0.00")
    @DecimalMax(value = "100.00")
    private BigDecimal proficiencyLevel;

    @Schema(description = "Număr luni experiență", required = true, example = "24")
    @NotNull
    @Min(0)
    private Integer experienceMonths;

    @Schema(description = "Data ultimei utilizări (YYYY-MM-DD)", required = true, example = "2024-10-01")
    @NotNull
    private LocalDate lastUsedDate;

    @Schema(description = "Confidence score (0.00 - 100.00)", required = false, example = "88.00")
    @DecimalMin(value = "0.00")
    @DecimalMax(value = "100.00")
    private BigDecimal confidenceScore;
}