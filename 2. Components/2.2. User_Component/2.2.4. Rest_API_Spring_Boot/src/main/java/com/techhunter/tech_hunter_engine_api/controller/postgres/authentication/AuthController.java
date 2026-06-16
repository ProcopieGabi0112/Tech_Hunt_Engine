package com.techhunter.tech_hunter_engine_api.controller.postgres.authentication;

import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthRequest;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.AuthResponse;
import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.RegisterRequest;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication.AuthService;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.authentication.UserService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UserService userService; // 🔥 adăugat

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @RequestBody AuthRequest request,
            HttpServletRequest httpRequest
    ) {
        AuthResponse response = authService.login(request);

        // 🔥 Extragem domeniul din Host (ex: 192.168.50.233:3000 → 192.168.50.233)
        String host = httpRequest.getHeader("Host");
        String domain = host.split(":")[0];

        ResponseCookie cookie = ResponseCookie.from("token", response.getToken())
                .httpOnly(true)
                .secure(false)
                .path("/")
                .sameSite("Lax")
                .domain(domain)   // 🔥 FIXUL MAGIC
                .maxAge(24 * 60 * 60)
                .build();

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .body(response);
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout() {
        return ResponseEntity.ok("Logged out successfully");
    }

    // ⭐⭐⭐ FORGOT PASSWORD
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        userService.generateResetToken(email);
        return ResponseEntity.ok("If the email exists, a reset link was sent.");
    }

    // ⭐⭐⭐ RESET PASSWORD
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> body) {
        String token = body.get("token");
        String newPassword = body.get("newPassword");

        userService.resetPassword(token, newPassword);

        return ResponseEntity.ok("Password updated successfully");
    }
}