package com.example.jammer.domain.repository;

import com.example.jammer.domain.model.User;
import org.springframework.context.annotation.Bean;

import java.util.Optional;

public interface UserRepository {
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);

    Optional<User> findById(int id);
    Optional<User> findByEmail(String email);

    User save(User user);
}

