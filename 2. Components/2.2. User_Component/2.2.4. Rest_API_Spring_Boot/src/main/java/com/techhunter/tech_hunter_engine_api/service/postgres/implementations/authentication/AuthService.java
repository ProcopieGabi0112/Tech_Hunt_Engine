package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthRequest;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthResponse;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.RegisterRequest;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.RoleEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.RoleRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.config.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final RoleRepository roleRepository;
    private final JwtService jwtService;

    public AuthResponse login(AuthRequest request) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        UserEntity user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // 🔥 Token cu rol
        String token = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(token)
                .roleId(user.getRole().getRoleId())
                .roleName(user.getRole().getName())
                .build();
    }

    public AuthResponse register(RegisterRequest request) {

        UserEntity user = new UserEntity();

        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setGender(request.getGender());
        user.setPhone(request.getPhone());

        // 🔥 ROL DEFAULT
        RoleEntity defaultRole = roleRepository.findByName("STUDENT")
                .orElseThrow(() -> new RuntimeException("Default role not found"));
        user.setRole(defaultRole);

        user.setAccountStatus("unlocked");
        user.setProfileApprovedFlag("N");
        user.setReportSentFlag("N");
        user.setDeletedFlag("N");
        user.setSourceSystem("db_env");
        user.setSyncStatus("synced");
        user.setSyncVersion(1L);
        user.setLastSyncedAt(LocalDateTime.now());

        // 🔥 Salvăm userul
        UserEntity savedUser = userRepository.save(user);

        // 🔥 Token cu rol (nu fără!)
        String token = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(token)
                .roleId(savedUser.getRole().getRoleId())
                .roleName(savedUser.getRole().getName())
                .build();
    }
}
