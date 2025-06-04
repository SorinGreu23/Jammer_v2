package com.example.jammer.domain.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class User {
    @Getter
    @Setter
    private Integer id;

    @Getter
    @Setter
    private String username;

    @Getter
    @Setter
    private String email;

    @Getter
    @Setter
    private String passwordHash;

    @Getter
    @Setter
    private String firstName;

    @Getter
    @Setter
    private String lastName;

    @Getter
    @Setter
    private Date createdAt;

    public User(Integer id, String username, String email, String passwordHash, String firstName, String lastName, Date createdAt) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.firstName = firstName;
        this.lastName = lastName;
        this.createdAt = createdAt;
    }
}
