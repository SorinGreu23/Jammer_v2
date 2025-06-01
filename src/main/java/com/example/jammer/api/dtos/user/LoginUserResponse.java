package com.example.jammer.api.dtos.user;

import lombok.Getter;
import lombok.Setter;

public class LoginUserResponse {
    @Getter
    @Setter
    private int userId;

    @Getter
    @Setter
    private String username;

    @Getter
    @Setter
    private String email;

    public LoginUserResponse(int userId, String username, String email) {
        this.userId = userId;
        this.username = username;
        this.email = email;
    }
}
