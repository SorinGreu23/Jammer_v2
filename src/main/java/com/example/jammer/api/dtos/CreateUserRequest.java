package com.example.jammer.api.dtos;

import lombok.Getter;
import lombok.Setter;

public class CreateUserRequest {
    @Getter
    @Setter
    private String username;

    @Getter
    @Setter
    private String email;

    @Getter
    @Setter
    private String password;

    public CreateUserRequest(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
    }
}
