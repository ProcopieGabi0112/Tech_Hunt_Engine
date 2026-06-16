package com.techhunter.tech_hunter_engine_api.controller.authentication;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.RoleEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.user.UserManagementService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private UserManagementService userManagementService;

    // -----------------------------------------------------
    // GET /users/me
    // -----------------------------------------------------
    @Test
    @WithMockUser(username = "test@mail.com", roles = "STUDENT")
    void getMyProfile_shouldReturnProfile() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);
        user.setEmail("test@mail.com");
        user.setFirstName("John");
        user.setLastName("Doe");
        RoleEntity role = new RoleEntity();
        role.setRoleId(4L);
        role.setName("STUDENT");
        user.setRole(role);
        user.setPhone("123");
        user.setGender("M");

        when(userRepository.findByEmail("test@mail.com")).thenReturn(Optional.of(user));

        mockMvc.perform(get("/users/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("test@mail.com"))
                .andExpect(jsonPath("$.firstName").value("John"));
    }

    // -----------------------------------------------------
    // PUT /users/me
    // -----------------------------------------------------
    @Test
    @WithMockUser(username = "test@mail.com", roles = "STUDENT")
    void updateMyProfile_shouldUpdateAndReturnUser() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);
        user.setEmail("test@mail.com");
        user.setSyncVersion(1L);

        when(userRepository.findByEmail("test@mail.com")).thenReturn(Optional.of(user));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        mockMvc.perform(put("/users/me")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "firstName": "New",
                                  "lastName": "Name",
                                  "phone": "999",
                                  "gender": "F",
                                  "nativeLangCode": 1,
                                  "locationId": 10,
                                  "supervizorId": 5
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("New"))
                .andExpect(jsonPath("$.profileApprovedFlag").value("N"));
    }

    // -----------------------------------------------------
    // POST /users/me/profile-image
    // -----------------------------------------------------
    @Test
    @WithMockUser(username = "test@mail.com", roles = "STUDENT")
    void uploadProfileImage_shouldSaveImage() throws Exception {

        UserEntity user = new UserEntity();
        user.setEmail("test@mail.com");

        when(userRepository.findByEmail("test@mail.com")).thenReturn(Optional.of(user));
        when(userRepository.save(any())).thenReturn(user);

        MockMultipartFile file = new MockMultipartFile(
                "file", "test.jpg", "image/jpeg", "abc".getBytes()
        );

        mockMvc.perform(multipart("/users/me/profile-image").file(file))
                .andExpect(status().isOk())
                .andExpect(content().string("Image uploaded"));
    }

    // -----------------------------------------------------
    // GET /users/me/profile-image
    // -----------------------------------------------------
    @Test
    @WithMockUser(username = "test@mail.com", roles = "STUDENT")
    void getProfileImage_shouldReturnImage() throws Exception {

        UserEntity user = new UserEntity();
        user.setEmail("test@mail.com");
        user.setProfileImage("abc".getBytes());

        when(userRepository.findByEmail("test@mail.com")).thenReturn(Optional.of(user));

        mockMvc.perform(get("/users/me/profile-image"))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "image/jpeg"))
                .andExpect(content().bytes("abc".getBytes()));
    }

    // -----------------------------------------------------
    // GET /users/all (ADMIN only)
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "ADMIN")
    void getAllActiveUsers_shouldReturnList() throws Exception {

        when(userRepository.findByDeletedFlag("N")).thenReturn(List.of(new UserEntity()));

        mockMvc.perform(get("/users/all"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(roles = "USER")
    void getAllActiveUsers_shouldReturn403_forNonAdmin() throws Exception {
        mockMvc.perform(get("/users/all"))
                .andExpect(status().isForbidden());
    }

    // -----------------------------------------------------
    // GET /users/{id}
    // -----------------------------------------------------
    @Test
    @WithMockUser
    void getById_shouldReturnUser() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        mockMvc.perform(get("/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1));
    }

    // -----------------------------------------------------
    // PUT /users/{id}
    // -----------------------------------------------------
    @Test
    @WithMockUser
    void updateUser_shouldUpdateAndReturnUser() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);
        user.setSyncVersion(1L);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        mockMvc.perform(put("/users/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "firstName": "Updated",
                                  "lastName": "User"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("Updated"));
    }

    // -----------------------------------------------------
    // GET /users/supervisors
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "STUDENT")
    void getSupervisors_shouldReturnList() throws Exception {

        when(userManagementService.getSupervisors()).thenReturn(List.of());

        mockMvc.perform(get("/users/supervisors"))
                .andExpect(status().isOk());
    }

    // -----------------------------------------------------
    // DELETE /users/{id}
    // -----------------------------------------------------
    @Test
    @WithMockUser
    void deleteUser_shouldDelete() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        mockMvc.perform(delete("/users/1"))
                .andExpect(status().isOk());

        verify(userRepository).deleteById(1L);
    }

    // -----------------------------------------------------
    // GET /users/deleted (ADMIN only)
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "ADMIN")
    void getDeletedUsers_shouldReturnList() throws Exception {

        when(userRepository.findByDeletedFlag("Y")).thenReturn(List.of());

        mockMvc.perform(get("/users/deleted"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(roles = "USER")
    void getDeletedUsers_shouldReturn403_forNonAdmin() throws Exception {
        mockMvc.perform(get("/users/deleted"))
                .andExpect(status().isForbidden());
    }

    // -----------------------------------------------------
    // PATCH /users/{id}/deactivate
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "ADMIN")
    void deactivateUser_shouldSetDeletedFlagY() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        mockMvc.perform(patch("/users/1/deactivate"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.deletedFlag").value("Y"));
    }

    // -----------------------------------------------------
    // PATCH /users/{id}/restore
    // -----------------------------------------------------
    @Test
    @WithMockUser(roles = "ADMIN")
    void restoreUser_shouldSetDeletedFlagN() throws Exception {

        UserEntity user = new UserEntity();
        user.setUserId(1L);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        mockMvc.perform(patch("/users/1/restore"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.deletedFlag").value("N"));
    }
}

