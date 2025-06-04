package com.example.jammer.api.dtos.user;

import lombok.Getter;
import lombok.Setter;

public class UpdateUserProfileRequest {
    @Getter
    @Setter
    private String firstName;

    @Getter
    @Setter
    private String lastName;

    public UpdateUserProfileRequest() {
    }

    public UpdateUserProfileRequest(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
    }
} 