package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class InviteUserRequest {
    @Getter
    @Setter
    private String usernameOrEmail;

    @Getter
    @Setter
    private Integer boardId;

    public InviteUserRequest() {}

    public InviteUserRequest(String usernameOrEmail, Integer boardId) {
        this.usernameOrEmail = usernameOrEmail;
        this.boardId = boardId;
    }
} 