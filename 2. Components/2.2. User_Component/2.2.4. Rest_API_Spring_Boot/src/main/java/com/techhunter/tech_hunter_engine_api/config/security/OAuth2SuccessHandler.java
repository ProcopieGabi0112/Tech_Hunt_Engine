package com.techhunter.tech_hunter_engine_api.config.security;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.RoleEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.RoleRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException {

        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();

        boolean isGoogle = oAuth2User.getAttributes().get("given_name") != null;
        boolean isGitHub = oAuth2User.getAttributes().get("login") != null;

        String email = (String) oAuth2User.getAttributes().get("email");

        if (email == null && isGitHub) {
            email = oAuth2User.getAttributes().get("login") + "@github.com";
        }

        UserEntity user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {

            RoleEntity defaultRole = roleRepository.findByName("STUDENT")
                    .orElseThrow(() -> new RuntimeException("Default role STUDENT not found"));

            user = new UserEntity();
            user.setEmail(email);
            user.setRole(defaultRole);

            String firstName = null;
            String lastName = null;

            if (isGoogle) {
                firstName = (String) oAuth2User.getAttributes().get("given_name");
                lastName = (String) oAuth2User.getAttributes().get("family_name");
            }

            if (isGitHub) {
                String login = (String) oAuth2User.getAttributes().get("login");
                String name = (String) oAuth2User.getAttributes().get("name");

                if (name != null && name.contains(" ")) {
                    firstName = capitalize(name.split(" ")[0]);
                    lastName = capitalize(name.split(" ")[1]);
                } else if (name != null) {
                    firstName = capitalize(name);
                    lastName = "";
                } else {
                    firstName = capitalize(login);
                    lastName = "";
                }
            }

            if (firstName == null) firstName = "User";
            if (lastName == null) lastName = "";

            user.setFirstName(firstName);
            user.setLastName(lastName);

            user.setPassword("OAUTH2");
            user.setDateOfBirth(LocalDate.of(2000, 1, 1));
            user.setAccountStatus("unlocked");
            user.setProfileApprovedFlag("N");
            user.setReportSentFlag("N");
            user.setDeletedFlag("N");

            user.setCreationDate(LocalDateTime.now());
            user.setCreatedBy("OAUTH2");
            user.setLastUpdateDate(LocalDateTime.now());
            user.setLastUpdatedBy("OAUTH2");

            user.setSourceSystem("db_env");
            user.setSyncStatus("synced");
            user.setSyncVersion(1L);
            user.setLastSyncedAt(LocalDateTime.now());

            userRepository.save(user);
        }

        // Generate token
        String token = jwtService.generateToken(user);

        String host = request.getHeader("Host");
        String domain = host.split(":")[0];

        ResponseCookie cookie = ResponseCookie.from("token", token)
                .httpOnly(true)
                .secure(false)
                .path("/")
                .sameSite("Lax")
                .domain(domain)   // 🔥 FIXUL MAGIC
                .maxAge(60L * 60 * 24 * 30)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());

        // 🔥 FRONTEND ORIGIN DINAMIC
        String frontendOrigin = request.getHeader("Origin");
        if (frontendOrigin == null) {
            frontendOrigin = "http://localhost:3000";
        }

        // 🔥 Redirect by role (dinamic)
        String redirectUrl = switch (user.getRole().getName()) {
            case "ADMIN" -> frontendOrigin + "/6-admin";
            case "MANAGER" -> frontendOrigin + "/5-manager";
            case "SPECIALIST_HR" -> frontendOrigin + "/4-specialist_hr";
            case "STUDENT" -> frontendOrigin + "/3-student";
            default -> frontendOrigin + "/1-landing_page";
        };

        response.sendRedirect(redirectUrl);
    }

    private String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }
}