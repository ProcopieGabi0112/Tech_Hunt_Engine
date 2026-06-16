package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.hibernate.validator.internal.util.Contracts.assertNotNull;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailService emailService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserServiceImpl userService;

    // -------------------------
    // TESTE generateResetToken
    // -------------------------

    @Test
    void generateResetToken_shouldDoNothing_whenEmailNotFound() {
        when(userRepository.findByEmail("test@test.com"))
                .thenReturn(Optional.empty());

        userService.generateResetToken("test@test.com");

        verify(userRepository, never()).save(any());
        verify(emailService, never()).sendResetEmail(any(), any());
    }

    @Test
    void generateResetToken_shouldGenerateTokenAndSendEmail_whenUserExists() {
        UserEntity user = new UserEntity();
        user.setEmail("test@test.com");

        when(userRepository.findByEmail("test@test.com"))
                .thenReturn(Optional.of(user));

        userService.generateResetToken("test@test.com");

        assertNotNull(user.getResetToken());
        assertNotNull(user.getResetTokenExpiry());

        verify(userRepository).save(user);
        verify(emailService).sendResetEmail(eq("test@test.com"), anyString());
    }

    // -------------------------
    // TESTE resetPassword
    // -------------------------

    @Test
    void resetPassword_shouldThrowException_whenTokenInvalid() {
        when(userRepository.findByResetToken("abc"))
                .thenReturn(Optional.empty());

        assertThrows(RuntimeException.class,
                () -> userService.resetPassword("abc", "newPass"));
    }

    @Test
    void resetPassword_shouldThrowException_whenTokenExpired() {
        UserEntity user = new UserEntity();
        user.setResetTokenExpiry(LocalDateTime.now().minusMinutes(1));

        when(userRepository.findByResetToken("abc"))
                .thenReturn(Optional.of(user));

        assertThrows(RuntimeException.class,
                () -> userService.resetPassword("abc", "newPass"));
    }

    @Test
    void resetPassword_shouldUpdatePassword_whenTokenValid() {
        UserEntity user = new UserEntity();
        user.setResetTokenExpiry(LocalDateTime.now().plusMinutes(10));

        when(userRepository.findByResetToken("abc"))
                .thenReturn(Optional.of(user));

        when(passwordEncoder.encode("newPass"))
                .thenReturn("encodedPass");

        userService.resetPassword("abc", "newPass");

        assertEquals("encodedPass", user.getPassword());
        assertNull(user.getResetToken());
        assertNull(user.getResetTokenExpiry());

        verify(userRepository).save(user);
    }
}