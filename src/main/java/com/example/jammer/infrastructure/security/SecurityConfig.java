package com.example.jammer.infrastructure.security;

import com.example.jammer.domain.service.PasswordHasher;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SecurityConfig {
    @Bean
    public PasswordHasher passwordHasher() {
        return new PasswordHasherImpl();
    }
}
