package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.authentication.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void generateResetToken(String email) {

        UserEntity user = userRepository.findByEmail(email).orElse(null);

        // Nu dezvăluim dacă emailul există
        if (user == null) {
            return;
        }

        String token = UUID.randomUUID().toString();

        user.setResetToken(token);
        user.setResetTokenExpiry(LocalDateTime.now().plusMinutes(15));

        userRepository.save(user);

        emailService.sendResetEmail(user.getEmail(), token);
    }

    @Override
    public void resetPassword(String token, String newPassword) {

        UserEntity user = userRepository.findByResetToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid token"));

        if (user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Token expired");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setResetToken(null);
        user.setResetTokenExpiry(null);

        userRepository.save(user);
    }


}