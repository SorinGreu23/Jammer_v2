package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class AcceptInvitationRequest {
    @Getter
    @Setter
    private String token;

    public AcceptInvitationRequest() {}

    public AcceptInvitationRequest(String token) {
        this.token = token;
    }
} 