package com.techhunter.tech_hunter_engine_api.dto.postgres.skill;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TechnologyDTO {
    private Long technologyCode;
    private String name;
    private Long technologyTypeCode; // <--- important
    // alte câmpuri după nevoie
}
