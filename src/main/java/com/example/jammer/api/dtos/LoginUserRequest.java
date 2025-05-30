package com.example.jammer.api.dtos;

import lombok.Getter;
import lombok.Setter;


public class LoginUserRequest {
    @Getter
    @Setter
    private String email;

    @Getter
    @Setter
    private String password;

    public LoginUserRequest(String email, String password) {
        this.email = email;
        this.password = password;
    }
}
