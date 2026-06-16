package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Schema(name = "UpdateUserSkillDTO", description = "Payload pentru actualizarea unei competențe a utilizatorului (partial update permis)")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateUserSkillDTO {

    @Schema(description = "Nivel de proficiency (0.00 - 100.00). Null = nu se modifică", example = "82.25")
    @DecimalMin(value = "0.00")
    @DecimalMax(value = "100.00")
    private BigDecimal proficiencyLevel;

    @Schema(description = "Număr luni experiență. Null = nu se modifică", example = "36")
    @Min(0)
    private Integer experienceMonths;

    @Schema(description = "Data ultimei utilizări (YYYY-MM-DD). Null = nu se modifică", example = "2025-01-15")
    private LocalDate lastUsedDate;

    @Schema(description = "Confidence score (0.00 - 100.00). Null = nu se modifică", example = "90.00")
    @DecimalMin(value = "0.00")
    @DecimalMax(value = "100.00")
    private BigDecimal confidenceScore;
}
