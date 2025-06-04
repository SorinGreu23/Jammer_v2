package com.example.jammer.api.dtos.user;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserResponse {
    private Integer userId;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String createdAt;
    private Integer boardsCount;
    private Integer tasksCount;
    private Integer projectsCount;
    private Integer collaborationsCount;

    public UserResponse(Integer userId, String username, String email, String firstName, String lastName, String createdAt) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.createdAt = createdAt;
        this.boardsCount = 0;
        this.tasksCount = 0;
        this.projectsCount = 0;
        this.collaborationsCount = 0;
    }
} 