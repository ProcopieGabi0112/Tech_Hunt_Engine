package com.techhunter.tech_hunter_engine_api.model.postgres.certification;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserLevelId implements Serializable {

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "lang_level_id")
    private Long langLevelId;
}