package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.math.BigDecimal;

@Schema(name = "TechnologyTypeDTO", description = "DTO pentru Technology Type (dropdown)")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TechnologyTypeDTO {
    private Long technologyTypeCode;
    private String name;
    private BigDecimal rating;
    private String description;
}
