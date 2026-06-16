package com.techhunter.tech_hunter_engine_api.controller.postgres.user;

import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.AddUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UpdateUserSkillDTO;
import com.techhunter.tech_hunter_engine_api.dto.postgres.skill.UserSkillResponseDTO;
import com.techhunter.tech_hunter_engine_api.config.security.SecurityUtils;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.skill.UserSkillService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users/me/skills")
public class UserSkillController {

    private final UserSkillService userSkillService;

    public UserSkillController(UserSkillService userSkillService) {
        this.userSkillService = userSkillService;
    }

    // TODO: replace getCurrentUserId() with real security principal extraction
    private Long getCurrentUserId() {
        Long id = SecurityUtils.getCurrentUserIdFromContext();
        if (id == null) {
            throw new IllegalStateException("Authenticated user id not found");
        }
        return id;
    }

    @GetMapping
    @Operation(summary = "Get current user's skills")
    public ResponseEntity<List<UserSkillResponseDTO>> getMySkills() {
        Long userId = getCurrentUserId();
        List<UserSkillResponseDTO> list = userSkillService.getUserSkills(userId);
        return ResponseEntity.ok(list);
    }

    @PostMapping
    @Operation(summary = "Add a skill to current user")
    public ResponseEntity<Void> addSkill(@Valid @RequestBody AddUserSkillDTO dto) {
        Long userId = getCurrentUserId();
        userSkillService.addUserSkill(userId, dto);
        return ResponseEntity.status(201).build();
    }

    @PutMapping("/{skillCode}")
    @Operation(summary = "Update a user's skill (partial update allowed)")
    public ResponseEntity<Void> updateSkill(@PathVariable Long skillCode,
                                            @Valid @RequestBody UpdateUserSkillDTO dto) {
        Long userId = getCurrentUserId();
        userSkillService.updateUserSkill(userId, skillCode, dto);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{skillCode}")
    @Operation(summary = "Delete (soft) a user's skill")
    public ResponseEntity<Void> deleteSkill(@PathVariable Long skillCode) {
        Long userId = getCurrentUserId();
        userSkillService.deleteUserSkill(userId, skillCode);
        return ResponseEntity.noContent().build();
    }
}
