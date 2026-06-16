package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserDTO;
import com.techhunter.tech_hunter_engine_api.mapper.postgres.user.UserMapper;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;




@ExtendWith(MockitoExtension.class)
class UserManagementServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserManagementServiceImpl userManagementService;

    // -----------------------------------------------------
    // GET SUPERVISORS - normal flow
    // -----------------------------------------------------
    @Test
    void getSupervisors_shouldReturnMappedDTOs() {

        UserEntity user1 = new UserEntity();
        user1.setUserId(100L);

        UserEntity user2 = new UserEntity();
        user2.setUserId(200L);

        UserDTO dto1 = new UserDTO(100L, "John", "Doe");
        UserDTO dto2 = new UserDTO(200L, "Jane", "Smith");

        when(userRepository.findByRole_RoleId(2L))
                .thenReturn(List.of(user1, user2));

        when(userMapper.toDto(user1)).thenReturn(dto1);
        when(userMapper.toDto(user2)).thenReturn(dto2);

        List<UserDTO> result = userManagementService.getSupervisors();

        assertEquals(2, result.size());
        assertEquals(100L, result.get(0).userId());
        assertEquals(200L, result.get(1).userId());
    }

    // -----------------------------------------------------
    // GET SUPERVISORS - empty list
    // -----------------------------------------------------
    @Test
    void getSupervisors_shouldReturnEmptyList_whenNoSupervisors() {

        when(userRepository.findByRole_RoleId(2L))
                .thenReturn(List.of());

        List<UserDTO> result = userManagementService.getSupervisors();

        assertTrue(result.isEmpty());
    }
}
