package com.example.jammer.domain.repository;

import com.example.jammer.domain.User;

public interface UsersRepository {
    boolean usernameExists(String username);
    boolean emailExists(String email);
    User getUser(int id);
    User getUserByEmail(String email);
    String getPasswordHash(String email);
    Integer createUser(String username, String email, String passwordHash);
}
