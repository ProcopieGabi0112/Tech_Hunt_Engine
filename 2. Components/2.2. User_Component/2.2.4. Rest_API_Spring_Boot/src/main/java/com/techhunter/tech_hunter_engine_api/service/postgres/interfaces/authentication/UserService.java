package com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.authentication;

public interface UserService {
    void generateResetToken(String email);
    void resetPassword(String token, String newPassword);

}
