package com.example.jammer.domain.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class BoardMember {
    @Getter
    private Long id;

    @Getter
    @Setter
    private Integer userId;

    @Getter
    @Setter
    private Integer boardId;

    @Getter
    @Setter
    private Boolean isAdmin;

    @Getter
    @Setter
    private Date invitedAt;

    @Getter
    @Setter
    private Date joinedAt;

    @Getter
    @Setter
    private String status; // PENDING, ACCEPTED, REJECTED

    @Getter
    @Setter
    private Integer invitedBy;

    // User details for joined queries
    @Getter
    @Setter
    private String username;

    @Getter
    @Setter
    private String email;

    @Getter
    @Setter
    private String firstName;

    @Getter
    @Setter
    private String lastName;

    @Getter
    @Setter
    private String inviterUsername;

    public BoardMember() {}

    public BoardMember(Long id, Integer userId, Integer boardId, Boolean isAdmin,
                      Date invitedAt, Date joinedAt, String status, Integer invitedBy) {
        this.id = id;
        this.userId = userId;
        this.boardId = boardId;
        this.isAdmin = isAdmin;
        this.invitedAt = invitedAt;
        this.joinedAt = joinedAt;
        this.status = status;
        this.invitedBy = invitedBy;
    }

    public BoardMember(Long id, Integer userId, Integer boardId, Boolean isAdmin,
                      Date invitedAt, Date joinedAt, String status, Integer invitedBy,
                      String username, String email, String firstName, String lastName,
                      String inviterUsername) {
        this(id, userId, boardId, isAdmin, invitedAt, joinedAt, status, invitedBy);
        this.username = username;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.inviterUsername = inviterUsername;
    }
} 