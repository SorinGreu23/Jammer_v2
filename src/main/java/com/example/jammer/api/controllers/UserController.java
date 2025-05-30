package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.CreateUserRequest;
import com.example.jammer.api.dtos.CreateUserResponse;
import com.example.jammer.application.user.CreateUserUseCase;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final CreateUserUseCase createUserUseCase;

    public UserController(CreateUserUseCase createUserUseCase) {
        this.createUserUseCase = createUserUseCase;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public CreateUserResponse registerUser(
            @RequestBody CreateUserRequest request) {
        return createUserUseCase.execute(request);
    }
}

