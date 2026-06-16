package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import com.techhunter.tech_hunter_engine_api.config.security.JwtService;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthRequest;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthResponse;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.RegisterRequest;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.RoleEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.RoleRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthService authService;

    // -------------------------
    // LOGIN TESTS
    // -------------------------

    @Test
    void login_shouldThrowException_whenUserNotFound() {
        AuthRequest request = new AuthRequest();
        request.setEmail("test@test.com");
        request.setPassword("pass");

        when(userRepository.findByEmail("test@test.com"))
                .thenReturn(Optional.empty());

        assertThrows(RuntimeException.class,
                () -> authService.login(request));
    }

    @Test
    void login_shouldReturnTokenAndRole_whenCredentialsValid() {
        AuthRequest request = new AuthRequest();
        request.setEmail("test@test.com");
        request.setPassword("pass");

        RoleEntity role = new RoleEntity();
        role.setRoleId(1L);
        role.setName("STUDENT");

        UserEntity user = new UserEntity();
        user.setEmail("test@test.com");
        user.setRole(role);

        when(userRepository.findByEmail("test@test.com"))
                .thenReturn(Optional.of(user));

        when(jwtService.generateToken(user))
                .thenReturn("jwt-token");

        AuthResponse response = authService.login(request);

        assertEquals("jwt-token", response.getToken());
        assertEquals(1L, response.getRoleId());
        assertEquals("STUDENT", response.getRoleName());
    }

    // -------------------------
    // REGISTER TESTS
    // -------------------------

    @Test
    void register_shouldThrowException_whenDefaultRoleMissing() {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("test@test.com");
        request.setPassword("pass");

        when(roleRepository.findByName("STUDENT"))
                .thenReturn(Optional.empty());

        assertThrows(RuntimeException.class,
                () -> authService.register(request));
    }

    @Test
    void register_shouldSaveUserAndReturnToken() {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("test@test.com");
        request.setPassword("pass");

        RoleEntity role = new RoleEntity();
        role.setRoleId(1L);
        role.setName("STUDENT");

        UserEntity savedUser = new UserEntity();
        savedUser.setRole(role);

        when(roleRepository.findByName("STUDENT"))
                .thenReturn(Optional.of(role));

        when(passwordEncoder.encode("pass"))
                .thenReturn("encoded-pass");

        when(userRepository.save(any(UserEntity.class)))
                .thenReturn(savedUser);

        when(jwtService.generateToken(any(UserEntity.class)))
                .thenReturn("jwt-token");

        AuthResponse response = authService.register(request);

        assertEquals("jwt-token", response.getToken());
        assertEquals(1L, response.getRoleId());
        assertEquals("STUDENT", response.getRoleName());
    }
}
