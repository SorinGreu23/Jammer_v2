package com.example.jammer.application.user;

import com.example.jammer.api.dtos.user.CreateUserRequest;
import com.example.jammer.api.dtos.user.CreateUserResponse;
import com.example.jammer.application.user.exception.EmailAlreadyExistsException;
import com.example.jammer.application.user.exception.UsernameAlreadyExistsException;
import com.example.jammer.domain.model.User;
import com.example.jammer.domain.repository.UserRepository;
import com.example.jammer.domain.service.PasswordHasher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDate;

@Service
public class CreateUserUseCase {
    private final UserRepository userRepository;
    private final PasswordHasher passwordHasher;

    public CreateUserUseCase(UserRepository userRepository, PasswordHasher passwordHasher) {
        this.userRepository = userRepository;
        this.passwordHasher = passwordHasher;
    }

    @Transactional
    public CreateUserResponse execute(CreateUserRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new UsernameAlreadyExistsException(request.getUsername());
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException(request.getEmail());
        }

        String hash = passwordHasher.hash(request.getPassword());
        User newUser = new User(
                0,
                request.getUsername(),
                request.getEmail(),
                hash,
                Date.valueOf(LocalDate.now())
        );

        User saved = userRepository.save(newUser);
        return new CreateUserResponse(
                saved.getId(),
                saved.getUsername(),
                saved.getEmail()
        );
    }
}

