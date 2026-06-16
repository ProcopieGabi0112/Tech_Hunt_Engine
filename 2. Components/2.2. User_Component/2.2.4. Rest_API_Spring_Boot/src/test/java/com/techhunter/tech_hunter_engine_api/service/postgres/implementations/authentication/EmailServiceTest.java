package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class EmailServiceTest {

    @Mock
    private JavaMailSender mailSender;

    @InjectMocks
    private EmailService emailService;

    @Test
    void sendResetEmail_shouldSendEmailWithCorrectFields() {

        // captor pentru mesajul trimis
        ArgumentCaptor<SimpleMailMessage> messageCaptor =
                ArgumentCaptor.forClass(SimpleMailMessage.class);

        String email = "test@test.com";
        String token = "abc123";

        emailService.sendResetEmail(email, token);

        // verificăm că mailSender.send() a fost apelat o singură dată
        verify(mailSender).send(messageCaptor.capture());

        SimpleMailMessage sentMessage = messageCaptor.getValue();

        // verificăm câmpurile
        assertEquals("support@techhunter.com", sentMessage.getFrom());
        assertEquals(email, sentMessage.getTo()[0]);
        assertEquals("Reset your password", sentMessage.getSubject());

        // verificăm că textul conține tokenul
        assertTrue(sentMessage.getText().contains(token));

        // verificăm că textul conține linkul corect
        assertTrue(sentMessage.getText().contains(
                "http://192.168.50.233:3000/2-authentication/4-reset_password?token=" + token
        ));
    }
}
