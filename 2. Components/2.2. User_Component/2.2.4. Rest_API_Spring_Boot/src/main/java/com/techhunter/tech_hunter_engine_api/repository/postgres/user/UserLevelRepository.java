package com.techhunter.tech_hunter_engine_api.repository.postgres.user;

import com.techhunter.tech_hunter_engine_api.model.postgres.certification.UserLevelId;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserLevelEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserLevelRepository extends JpaRepository<UserLevelEntity, UserLevelId> {

    List<UserLevelEntity> findByUser_UserId(Long userId);

    boolean existsByUser_UserIdAndLangLevel_LangLevelId(Long userId, Long langLevelId);

    void deleteByUser_UserIdAndLangLevel_LangLevelId(Long userId, Long langLevelId);

    Optional<UserLevelEntity> findByUser_UserIdAndLangLevel_LangLevelId(Long userId, Long langLevelId);
}
