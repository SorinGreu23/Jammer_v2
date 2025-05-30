package com.example.jammer.persistence;

import com.example.jammer.domain.User;
import com.example.jammer.domain.repository.UsersRepository;

import java.sql.Connection;

public class UserRepositoryImpl implements UsersRepository {
    @Override
    public boolean usernameExists(String username) {
        var sql = "SELECT COUNT(*) FROM [Workspace].[Users] WHERE [Username] = ?";
        try(Connection conn = )

        return false;
    }

    @Override
    public boolean emailExists(String email) {
        return false;
    }

    @Override
    public User getUser(int id) {
        return null;
    }

    @Override
    public User getUserByEmail(String email) {
        return null;
    }

    @Override
    public String getPasswordHash(String email) {
        return "";
    }

    @Override
    public Integer createUser(String username, String email, String passwordHash) {
        return 0;
    }
}
