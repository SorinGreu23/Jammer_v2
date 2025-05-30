package com.example.jammer.domain;

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
    private Date createdAt;
}
