package com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendResetEmail(String to, String token) {

        String link = "http://192.168.50.233:3000/2-authentication/4-reset_password?token=" + token;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("support@techhunter.com");   // 🔥 OBLIGATORIU
        message.setTo(to);
        message.setSubject("Reset your password");
        message.setText(
                "Ai cerut resetarea parolei.\n\n" +
                        "Apasă pe link pentru a seta o parolă nouă:\n" +
                        link + "\n\n" +
                        "Linkul expiră în 15 minute."
        );

        mailSender.send(message);
    }
}
