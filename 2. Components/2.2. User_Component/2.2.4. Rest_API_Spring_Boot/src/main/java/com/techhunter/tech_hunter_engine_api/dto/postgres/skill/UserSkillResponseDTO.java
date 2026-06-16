package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Schema(name = "UserSkillResponseDTO", description = "DTO folosit pentru afișarea competențelor utilizatorului")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSkillResponseDTO {

    @Schema(description = "Codul skill-ului", example = "123")
    private Long skillCode;

    @Schema(description = "Numele skill-ului", example = "Streams API")
    private String skillName;

    @Schema(description = "Numele versiunii asociate", example = "Java 17")
    private String versionName;

    @Schema(description = "Numele tehnologiei", example = "Java")
    private String technologyName;

    @Schema(description = "Numele tipului de tehnologie", example = "Programming Language")
    private String technologyTypeName;

    @Schema(description = "Nivel de proficiency (0.00 - 100.00)", example = "75.50")
    private BigDecimal proficiencyLevel;

    @Schema(description = "Experiență în luni", example = "24")
    private Integer experienceMonths;

    @Schema(description = "Data ultimei utilizări", example = "2024-10-01")
    private LocalDate lastUsedDate;

    @Schema(description = "Confidence score (0.00 - 100.00)", example = "88.00")
    private BigDecimal confidenceScore;
}
