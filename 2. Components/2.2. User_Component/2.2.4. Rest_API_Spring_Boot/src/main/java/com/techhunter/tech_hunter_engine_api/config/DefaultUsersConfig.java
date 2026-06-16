package com.techhunter.tech_hunter_engine_api.config;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.RoleRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Configuration
@ConditionalOnProperty(
        name = "app.default-users.enabled",
        havingValue = "true",
        matchIfMissing = true
)
@RequiredArgsConstructor
public class DefaultUsersConfig {

    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initDefaultUsers(
            UserRepository userRepository,
            RoleRepository roleRepository
    ) {
        return args -> {

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "admin_gabi@techhunter.com",
                    "Gabriel", "Procopie",
                    "AdminPass",
                    LocalDate.of(1997, 12, 1),
                    "+40753077460",
                    "M",
                    null,
                    null,
                    4L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "admin_teo@techhunter.com",
                    "Teodora", "Grecu",
                    "AdminPass",
                    LocalDate.of(1998, 3, 22),
                    "+40722772219",
                    "F",
                    null,
                    null,
                    4L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "manager_gabi@techhunter.com",
                    "Gabriel", "Procopie",
                    "ManagerPass",
                    LocalDate.of(1997, 12, 1),
                    "+40753077460",
                    "M",
                    null,
                    null,
                    3L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "manager_teo@techhunter.com",
                    "Teodora", "Grecu",
                    "ManagerPass",
                    LocalDate.of(1998, 3, 22),
                    "+40722772219",
                    "F",
                    null,
                    null,
                    3L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "specialist_hr_gabi@techhunter.com",
                    "Gabriel", "Procopie",
                    "SpecialistHrPass",
                    LocalDate.of(1997, 12, 1),
                    "+40753077460",
                    "M",
                    null,
                    null,
                    2L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "specialist_hr_teo@techhunter.com",
                    "Teodora", "Grecu",
                    "SpecialistHrPass",
                    LocalDate.of(1998, 3, 22),
                    "+40722772219",
                    "F",
                    null,
                    null,
                    2L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "student_gabi@techhunter.com",
                    "Gabriel", "Procopie",
                    "StudentPass",
                    LocalDate.of(1997, 12, 1),
                    "+40753077460",
                    "M",
                    null,
                    null,
                    1L
            );

            createUserIfNotExists(
                    userRepository, roleRepository,
                    "student_teo@techhunter.com",
                    "Teodora", "Grecu",
                    "StudentPass",
                    LocalDate.of(1998, 3, 22),
                    "+40722772219",
                    "F",
                    null,
                    null,
                    1L
            );
        };
    }

    private void createUserIfNotExists(
            UserRepository userRepository,
            RoleRepository roleRepository,
            String email,
            String firstName,
            String lastName,
            String rawPassword,
            LocalDate dateOfBirth,
            String phone,
            String gender,
            Long nativeLangCode,
            Long locationId,
            Long roleId
    ) {
        if (!userRepository.existsByEmail(email)) {

            UserEntity user = new UserEntity();

            // BASIC FIELDS
            user.setEmail(email);
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setPassword(passwordEncoder.encode(rawPassword));
            user.setDateOfBirth(dateOfBirth);
            user.setPhone(phone);
            user.setGender(gender);

            // OPTIONAL DOCUMENTS
            user.setProfileImage(null);
            user.setProfileDocument(null);
            user.setReportDocument(null);

            // FOREIGN KEYS
            user.setNativeLangCode(nativeLangCode);
            user.setLocationId(locationId);
            user.setSupervizorId(null);

            // ROLE (ManyToOne)
            user.setRole(roleRepository.findById(roleId).orElseThrow());

            // REQUIRED FLAGS
            user.setAccountStatus("unlocked");
            user.setProfileApprovedFlag("N");
            user.setReportSentFlag("N");
            user.setDeletedFlag("N");

            // TECHNICAL FIELDS
            LocalDateTime now = LocalDateTime.now();
            user.setCreationDate(now);
            user.setCreatedBy("SYSTEM");
            user.setLastUpdateDate(now);
            user.setLastUpdatedBy("SYSTEM");
            user.setSourceSystem("db_env");
            user.setSyncStatus("synced");
            user.setSyncVersion(1L);
            user.setLastSyncedAt(now);

            userRepository.save(user);
        }
    }
}