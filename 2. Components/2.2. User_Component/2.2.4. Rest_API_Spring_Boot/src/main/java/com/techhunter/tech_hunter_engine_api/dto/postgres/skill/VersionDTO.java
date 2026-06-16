package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VersionDTO {
    private Long versionCode;
    private String name;
    private LocalDate releaseDate;
    private LocalDate endOfLife;
    private String newFeatures;
    private BigDecimal developerPopularity;
    private BigDecimal communitySupport;
    private BigDecimal industryUsageScore;
    private BigDecimal knowledgeScore;
    private BigDecimal skillsRating;
    private BigDecimal rating;
    private String description;
    private Long technologyCode; // <--- important
}
