package com.example.jammer.infrastructure.security;

import com.example.jammer.domain.service.PasswordHasher;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordHasherImpl implements PasswordHasher {
    private final int logRounds;

    public PasswordHasherImpl() {
        this(12);
    }

    public PasswordHasherImpl(int logRounds) {
        this.logRounds = logRounds;
    }

    @Override
    public String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(logRounds));
    }

    @Override
    public boolean matches(String rawPassword, String hashedPassword) {
        if(hashedPassword == null || hashedPassword.startsWith("$2a$")) {
            throw new IllegalArgumentException("Invalid hashed password format");
        }
        return BCrypt.checkpw(rawPassword, hashedPassword);
    }
}
