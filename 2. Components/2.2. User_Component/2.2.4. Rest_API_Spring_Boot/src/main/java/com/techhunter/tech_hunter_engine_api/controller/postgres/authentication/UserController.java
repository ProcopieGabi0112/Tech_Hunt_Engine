package com.techhunter.tech_hunter_engine_api.controller.postgres.authentication;

import com.techhunter.tech_hunter_engine_api.dto.postgres.authentication.UserProfileDto;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user.UserManagementService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@Tag(name = "USER ENDPOINTS", description = "Main user actions")
@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;
    private final UserManagementService userManagementService;

    @PreAuthorize("hasAnyRole('ADMIN','MANAGER','SPECIALIST_HR','STUDENT')")
    @GetMapping("/me")
    public UserProfileDto getMyProfile(Authentication authentication) {

        // 1. Luăm emailul din token
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        UserEntity user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new UserProfileDto(
                user.getUserId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getRole().getName(),
                user.getPhone(),
                user.getGender(),
                user.getDateOfBirth(),
                user.getNativeLangCode(),
                user.getLocationId(),
                user.getSupervizorId(),
                user.getProfileApprovedFlag()
        );
    }

    @PreAuthorize("hasAnyRole('ADMIN','MANAGER','SPECIALIST_HR','STUDENT')")
    @PutMapping("/me")
    public UserEntity updateMyProfile(@RequestBody UserProfileDto updated) {

        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        UserEntity user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // câmpuri editabile
        user.setFirstName(updated.firstName());
        user.setLastName(updated.lastName());
        user.setPhone(updated.phone());
        user.setGender(updated.gender());
        user.setDateOfBirth(updated.dateOfBirth());
        user.setNativeLangCode(updated.nativeLangCode());
        user.setLocationId(updated.locationId());
        user.setSupervizorId(updated.supervizorId());

        // dacă userul modifică ceva → profilul trebuie reaprobat
        user.setProfileApprovedFlag("N");

        user.setLastUpdateDate(LocalDateTime.now());
        user.setSyncVersion(user.getSyncVersion() + 1);

        return userRepository.save(user);
    }

    @PostMapping("/me/profile-image")
    public ResponseEntity<?> uploadProfileImage(@RequestParam("file") MultipartFile file) throws IOException {

        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        UserEntity user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setProfileImage(file.getBytes());
        userRepository.save(user);

        return ResponseEntity.ok("Image uploaded");
    }

    @GetMapping("/me/profile-image")
    public ResponseEntity<byte[]> getProfileImage() {

        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        UserEntity user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        byte[] image = user.getProfileImage();

        if (image == null || image.length == 0) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity
                .ok()
                .header("Content-Type", "image/jpeg")
                .body(image);
    }


    // 2) GET /users/all
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/all")
    public List<UserEntity> getAllActiveUsers() {
        return userRepository.findByDeletedFlag("N");
    }

    @GetMapping("/{id}")
    public UserEntity getById(@PathVariable Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @PutMapping("/{id}")
    public UserEntity updateUser(
            @PathVariable Long id,
            @RequestBody UserEntity updated
    ) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setFirstName(updated.getFirstName());
        user.setLastName(updated.getLastName());
        user.setPhone(updated.getPhone());
        user.setGender(updated.getGender());
        user.setNativeLangCode(updated.getNativeLangCode());

        user.setLastUpdateDate(LocalDateTime.now());
        user.setSyncVersion(user.getSyncVersion() + 1);

        return userRepository.save(user);
    }

    @GetMapping("/supervisors")
    @PreAuthorize("hasAnyRole('STUDENT', 'SPECIALIST_HR', 'MANAGER', 'ADMIN')")
    public List<UserDTO> getSupervisors() {
        return userManagementService.getSupervisors();
    }

    // 5) DELETE /users/{id} – soft delete
    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        userRepository.deleteById(id);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/deleted")
    public List<UserEntity> getDeletedUsers() {
        return userRepository.findByDeletedFlag("Y");
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PatchMapping("/{id}/deactivate")
    public UserEntity deactivateUser(@PathVariable Long id) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setDeletedFlag("Y");
        user.setLastUpdateDate(LocalDateTime.now());
        return userRepository.save(user);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PatchMapping("/{id}/restore")
    public UserEntity restoreUser(@PathVariable Long id) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setDeletedFlag("N");
        user.setLastUpdateDate(LocalDateTime.now());
        return userRepository.save(user);
    }

}
