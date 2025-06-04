package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class InviteUserResponse {
    @Getter
    @Setter
    private String invitationType; // USER_FOUND, EMAIL_INVITATION

    @Getter
    @Setter
    private Integer userId;

    @Getter
    @Setter
    private String email;

    @Getter
    @Setter
    private String message;

    public InviteUserResponse() {}

    public InviteUserResponse(String invitationType, Integer userId, String email, String message) {
        this.invitationType = invitationType;
        this.userId = userId;
        this.email = email;
        this.message = message;
    }
} 