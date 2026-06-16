package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Optional;

import static org.hibernate.validator.internal.util.Contracts.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserDetailsServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserDetailsServiceImpl userDetailsService;

    @Test
    void loadUserByUsername_shouldThrowException_whenUserNotFound() {

        when(userRepository.findByEmail("test@test.com"))
                .thenReturn(Optional.empty());

        assertThrows(UsernameNotFoundException.class,
                () -> userDetailsService.loadUserByUsername("test@test.com"));
    }

    @Test
    void loadUserByUsername_shouldReturnUserDetails_whenUserExists() {

        UserEntity user = new UserEntity();
        user.setEmail("test@test.com");
        user.setPassword("encoded-pass");

        when(userRepository.findByEmail("test@test.com"))
                .thenReturn(Optional.of(user));

        UserDetails result = userDetailsService.loadUserByUsername("test@test.com");

        assertNotNull(result);
        assertEquals("test@test.com", result.getUsername());
        assertEquals("encoded-pass", result.getPassword());
    }
}
