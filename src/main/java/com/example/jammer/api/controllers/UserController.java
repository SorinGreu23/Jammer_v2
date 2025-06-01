package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.user.CreateUserRequest;
import com.example.jammer.api.dtos.user.CreateUserResponse;
import com.example.jammer.api.dtos.user.LoginUserRequest;
import com.example.jammer.api.dtos.user.LoginUserResponse;
import com.example.jammer.application.user.CreateUserUseCase;
import com.example.jammer.application.user.LoginUserUseCase;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final CreateUserUseCase createUserUseCase;
    private final LoginUserUseCase loginUserUseCase;

    public UserController(CreateUserUseCase createUserUseCase, LoginUserUseCase loginUserUseCase) {
        this.createUserUseCase = createUserUseCase;
        this.loginUserUseCase = loginUserUseCase;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public CreateUserResponse registerUser(
            @RequestBody CreateUserRequest request) {
        return createUserUseCase.execute(request);
    }

    @PostMapping("/login")
    @ResponseStatus(HttpStatus.OK)
    public LoginUserResponse loginUser(@RequestBody LoginUserRequest request) {
        return loginUserUseCase.execute(request);
    }
}

