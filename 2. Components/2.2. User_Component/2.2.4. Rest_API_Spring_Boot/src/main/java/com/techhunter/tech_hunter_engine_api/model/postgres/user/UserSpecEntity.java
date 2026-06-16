package com.techhunter.tech_hunter_engine_api.model.postgres.user;


import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.SpecializationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.specialization.UserSpecId;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Schema(name = "USER_SPEC TABLE", description = "Associates users with their academic specializations.")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "user_spec", schema = "db_owner")
@IdClass(UserSpecId.class)
public class UserSpecEntity {

    @Id
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "specialization_id")
    private SpecializationEntity specialization;

    @Id
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private UserEntity user;

    @Column(name = "graduation_date")
    private LocalDate graduationDate;
}
