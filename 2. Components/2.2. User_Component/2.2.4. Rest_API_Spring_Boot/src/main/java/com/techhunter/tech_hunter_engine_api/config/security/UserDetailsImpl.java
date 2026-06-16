package com.techhunter.tech_hunter_engine_api.config.security;

import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@RequiredArgsConstructor
public class UserDetailsImpl implements UserDetails {

    private final UserEntity user;

    // ⭐ Asta lipsea!
    public Long getUserId() {
        return user.getUserId();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // momentan nu ai obiect RoleEntity, doar roleId
        // putem returna o autoritate generică
        String roleName = "ROLE_" + user.getRole().getName();
        return List.of(() -> roleName);
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        // Spring Security cere un "username" → noi folosim email
        return user.getEmail();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // poți adapta după accountStatus
    }

    @Override
    public boolean isAccountNonLocked() {
        return !"LOCKED".equalsIgnoreCase(user.getAccountStatus());
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return !"DELETED".equalsIgnoreCase(user.getDeletedFlag());
    }
}