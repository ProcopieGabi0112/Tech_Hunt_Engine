package com.techhunter.tech_hunter_engine_api.model.postgres.specialization;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserSpecId implements Serializable {
    private Long specialization;
    private Long user;
}
