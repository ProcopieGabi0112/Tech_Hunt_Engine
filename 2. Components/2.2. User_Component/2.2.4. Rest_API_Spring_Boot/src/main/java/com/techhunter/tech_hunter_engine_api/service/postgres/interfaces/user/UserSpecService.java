package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user;



import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecViewDTO;

import java.time.LocalDate;
import java.util.List;

public interface UserSpecService {

    List<UserSpecDTO> getUserSpecializations(Long userId);

    void addUserSpecialization(UserSpecDTO dto);

    List<UserSpecViewDTO> getUserSpecializationsView(Long userId);

    void updateGraduationDate(Long userId, Long specializationId, LocalDate graduationDate);

    void deleteSpecialization(Long userId, Long specializationId);
}