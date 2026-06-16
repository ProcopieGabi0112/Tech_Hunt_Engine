package com.techhunter.tech_hunter_engine_api.controller.postgres.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.user.AddUserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UpdateUserLanguageDateDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.user.UserLanguageDTO;
import com.techhunter.tech_hunter_engine_api.config.security.UserDetailsImpl;
import com.techhunter.tech_hunter_engine_api.service.postgres.implementations.user.UserLanguageService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/users/me/languages")
@RequiredArgsConstructor
public class UserLanguageController {

    private final UserLanguageService userLanguageService;

    // GET all certifications for logged-in user
    @GetMapping
    public List<UserLanguageDTO> getUserLanguages(Principal principal) {
        Authentication auth = (Authentication) principal;
        UserDetailsImpl userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();

        return userLanguageService.getUserLanguages(userId);
    }

    // ADD certification
    @PostMapping
    public void addUserLanguage(Principal principal, @RequestBody AddUserLanguageDTO dto) {
        Authentication auth = (Authentication) principal;
        UserDetailsImpl userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();

        userLanguageService.addUserLanguage(userId, dto);
    }

    // DELETE certification
    @DeleteMapping("/{langLevelId}")
    public void deleteUserLanguage(Principal principal, @PathVariable Long langLevelId) {
        Authentication auth = (Authentication) principal;
        UserDetailsImpl userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();

        userLanguageService.deleteUserLanguage(userId, langLevelId);
    }

    @PutMapping("/{langLevelId}")
    public void updateUserLanguageDate(
            Principal principal,
            @PathVariable Long langLevelId,
            @RequestBody UpdateUserLanguageDateDTO dto
    ) {
        Authentication auth = (Authentication) principal;
        UserDetailsImpl userDetails = (UserDetailsImpl) auth.getPrincipal();
        Long userId = userDetails.getUserId();

        userLanguageService.updateUserLanguageDate(userId, langLevelId, dto);
    }

}
