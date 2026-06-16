package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserDTO;

import java.util.List;

public interface UserManagementService {
    List<UserDTO> getSupervisors();
}
