package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class AcceptInvitationResponse {
    @Getter
    @Setter
    private Integer boardId;

    @Getter
    @Setter
    private String message;

    public AcceptInvitationResponse() {}

    public AcceptInvitationResponse(Integer boardId, String message) {
        this.boardId = boardId;
        this.message = message;
    }
} 