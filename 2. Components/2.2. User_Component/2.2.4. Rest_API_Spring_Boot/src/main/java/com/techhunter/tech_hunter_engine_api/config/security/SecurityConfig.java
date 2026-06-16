package com.techhunter.tech_hunter_engine_api.config.security;


import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.authentication.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final UserDetailsServiceImpl userDetailsService;
    private final OAuth2SuccessHandler oAuth2SuccessHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                // ============================
                // CORS
                // ============================
                .cors(cors -> cors.configurationSource(request -> {
                    var config = new org.springframework.web.cors.CorsConfiguration();

                    config.setAllowedOriginPatterns(List.of(
                            "http://localhost:3000",
                            "http://127.0.0.1:3000",
                            "http://*.*.*.*:3000"
                    ));

                    config.setAllowedMethods(List.of("*")); // 🔥 toate metodele
                    config.setAllowedHeaders(List.of("*")); // 🔥 toate header-ele
                    config.setExposedHeaders(List.of("Set-Cookie")); // 🔥 expune cookie-ul
                    config.setAllowCredentials(true); // 🔥 permite cookie-uri

                    return config;
                }))

                // ============================
                // CSRF OFF (JWT)
                // ============================
                .csrf(csrf -> csrf.disable())

                // ============================
                // AUTH RULES
                // ============================
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/login", "/auth/register", "/auth/logout").permitAll()
                        .requestMatchers("/auth/forgot-password", "/auth/reset-password").permitAll()
                        .requestMatchers("/oauth2/**", "/login/oauth2/**").permitAll()

                        .requestMatchers(
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html"
                        ).permitAll()

                        .requestMatchers("/languages").permitAll()
                        .requestMatchers("/lang-levels").permitAll()
                        .requestMatchers("/technology-types").permitAll()
                        .requestMatchers("/technologies/**").permitAll()
                        .requestMatchers("/versions/**").permitAll()
                        .requestMatchers("/skills/**").permitAll()
                        .requestMatchers("/users/supervisors/**").permitAll()
                        .requestMatchers(
                                "/regions",
                                "/countries",
                                "/admin-units",
                                "/cities",
                                "/locations",
                                "/institutions",
                                "/specializations"
                        ).permitAll()

                        .requestMatchers("/users/me/languages/**")
                        .hasAnyRole("ADMIN", "MANAGER", "SPECIALIST_HR", "STUDENT")
                        .requestMatchers("/users/me/skills/**")
                        .hasAnyRole("ADMIN", "MANAGER", "SPECIALIST_HR", "STUDENT")
                        .requestMatchers("/users/me/specializations/**")
                        .hasAnyRole("ADMIN", "MANAGER", "SPECIALIST_HR", "STUDENT")
                        .requestMatchers("/users/me")
                        .hasAnyRole("ADMIN", "MANAGER", "SPECIALIST_HR", "STUDENT")

                        .requestMatchers("/users/all").hasRole("ADMIN")
                        .requestMatchers("/users/deleted").hasRole("ADMIN")
                        .requestMatchers("/users/*/deactivate").hasRole("ADMIN")
                        .requestMatchers("/users/*/restore").hasRole("ADMIN")

                        .anyRequest().authenticated()
                )

                // ============================
                // OAuth2
                // ============================
                .oauth2Client(Customizer.withDefaults())
                .oauth2Login(oauth -> oauth
                        .successHandler(oAuth2SuccessHandler)
                        .failureUrl("/auth/login?error")
                )

                // ============================
                // JWT STATELESS
                // ============================
                .sessionManagement(sess -> sess
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                .authenticationProvider(authenticationProvider())
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}

