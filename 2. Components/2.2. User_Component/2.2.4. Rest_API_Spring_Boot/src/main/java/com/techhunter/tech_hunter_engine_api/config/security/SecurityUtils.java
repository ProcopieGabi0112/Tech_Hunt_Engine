package com.techhunter.tech_hunter_engine_api.config.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.jwt.Jwt;

public final class SecurityUtils {

    private SecurityUtils() {}


    // EXTRACT USER ID
    public static Long extractUserIdFromJwt(Jwt jwt) {
        if (jwt == null) return null;
        Object claim = jwt.getClaim("user_id");
        if (claim == null) return null;
        try {
            return Long.valueOf(String.valueOf(claim));
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    public static Long getCurrentUserIdFromContext() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) return null;

        Object principal = auth.getPrincipal();

        if (principal instanceof Jwt jwt) {
            return extractUserIdFromJwt(jwt);
        }

        if (principal instanceof UserDetails ud) {
            try {
                var method = ud.getClass().getMethod("getUserId");
                Object id = method.invoke(ud);
                if (id != null) return Long.valueOf(String.valueOf(id));
            } catch (Exception ignored) {}
        }

        try {
            var m = principal.getClass().getMethod("getUserId");
            Object id = m.invoke(principal);
            if (id != null) return Long.valueOf(String.valueOf(id));
        } catch (Exception ignored) {}

        return null;
    }

    // -------------------------
    // EXTRACT USER EMAIL
    // -------------------------
    public static String getCurrentUserEmailFromContext() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) return null;

        Object principal = auth.getPrincipal();

        // Case 1: JWT authentication
        if (principal instanceof Jwt jwt) {
            Object email = jwt.getClaim("email");
            return email != null ? email.toString() : null;
        }

        // Case 2: UserDetailsImpl (login clasic)
        if (principal instanceof UserDetails ud) {
            try {
                var method = ud.getClass().getMethod("getEmail");
                Object email = method.invoke(ud);
                return email != null ? email.toString() : null;
            } catch (Exception ignored) {}
        }

        // Case 3: Custom principal
        try {
            var m = principal.getClass().getMethod("getEmail");
            Object email = m.invoke(principal);
            return email != null ? email.toString() : null;
        } catch (Exception ignored) {}

        return null;
    }
}