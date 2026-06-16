package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.user.UserMapper;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user.UserManagementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserManagementServiceImpl implements UserManagementService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Override
    public List<UserDTO> getSupervisors() {
        return userRepository.findByRole_RoleId(2L)
                .stream()
                .map(userMapper::toDto)
                .toList();
    }
}

