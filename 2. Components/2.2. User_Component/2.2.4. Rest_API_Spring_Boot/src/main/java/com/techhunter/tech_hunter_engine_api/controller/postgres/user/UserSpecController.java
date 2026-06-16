package com.techhunter.tech_hunter_engine_api.controller.postgres.user;

import com.techhunter.tech_hunter_engine_api.config.security.UserDetailsImpl;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserSpecViewDTO;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user.UserSpecService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/users/me/specializations")
@RequiredArgsConstructor
public class UserSpecController {

    private final UserSpecService userSpecService;

    @GetMapping
    public List<UserSpecDTO> getMySpecializations(Principal principal) {
        var auth = (Authentication) principal;
        var userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();
        return userSpecService.getUserSpecializations(userId);
    }

    @PostMapping
    public void addSpecialization(Principal principal, @RequestBody UserSpecDTO dto) {
        var auth = (Authentication) principal;
        var userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();
        UserSpecDTO fixed = new UserSpecDTO(dto.specializationId(), userId, dto.graduationDate());
        userSpecService.addUserSpecialization(fixed);
    }

    @GetMapping("/view")
    public List<UserSpecViewDTO> getMySpecializationsView(Principal principal) {
        var auth = (Authentication) principal;
        var userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();
        return userSpecService.getUserSpecializationsView(userId);
    }

    @PutMapping("/{specializationId}")
    public void updateGraduationDate(
            Principal principal,
            @PathVariable Long specializationId,
            @RequestBody Map<String, String> body
    ) {
        var auth = (Authentication) principal;
        var userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();

        LocalDate date = LocalDate.parse(body.get("graduationDate"));
        userSpecService.updateGraduationDate(userId, specializationId, date);
    }
    @Transactional
    @DeleteMapping("/{specializationId}")
    public void deleteSpecialization(Principal principal, @PathVariable Long specializationId) {
        var auth = (Authentication) principal;
        var userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();

        userSpecService.deleteSpecialization(userId, specializationId);
    }
}