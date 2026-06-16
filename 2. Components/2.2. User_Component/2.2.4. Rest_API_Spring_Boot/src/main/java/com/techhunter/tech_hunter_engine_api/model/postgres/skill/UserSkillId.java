package com.techhunter.tech_hunter_engine_api.model.postgres.skill;

import java.io.Serializable;
import java.util.Objects;

public class UserSkillId implements Serializable {
    private Long userId;
    private Long skillCode;

    public UserSkillId() {}

    public UserSkillId(Long userId, Long skillCode) {
        this.userId = userId;
        this.skillCode = skillCode;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserSkillId)) return false;
        UserSkillId that = (UserSkillId) o;
        return Objects.equals(userId, that.userId) && Objects.equals(skillCode, that.skillCode);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, skillCode);
    }
}
