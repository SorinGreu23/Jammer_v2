package com.example.jammer.application.user;

import com.example.jammer.api.dtos.LoginUserRequest;
import com.example.jammer.api.dtos.LoginUserResponse;
import com.example.jammer.application.user.exception.InvalidLoginException;
import com.example.jammer.domain.model.User;
import com.example.jammer.domain.repository.UserRepository;
import com.example.jammer.domain.service.PasswordHasher;
import org.springframework.stereotype.Service;

@Service
public class LoginUserUseCase {
    private final UserRepository userRepository;
    private final PasswordHasher passwordHasher;

    public LoginUserUseCase(UserRepository userRepository, PasswordHasher passwordHasher) {
        this.userRepository = userRepository;
        this.passwordHasher = passwordHasher;
    }

    public LoginUserResponse execute(LoginUserRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(InvalidLoginException::new);

        if (!passwordHasher.matches(request.getPassword(), user.getPasswordHash())) {
            throw new InvalidLoginException();
        }

        return new LoginUserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail()
        );
    }
}