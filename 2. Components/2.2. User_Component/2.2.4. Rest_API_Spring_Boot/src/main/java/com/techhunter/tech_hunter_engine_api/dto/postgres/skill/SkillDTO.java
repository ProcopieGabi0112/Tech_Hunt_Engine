package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.math.BigDecimal;

@Schema(name = "SkillDTO", description = "DTO pentru Skill (dropdown)")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SkillDTO {
    private Long skillCode;
    private String name;
    private BigDecimal rating;
    private String description;

    private Long versionCode;
    private String versionName;

    private Long technologyCode;
    private String technologyName;
}