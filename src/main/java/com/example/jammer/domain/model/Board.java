package com.example.jammer.domain.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class Board {
    @Getter
    private Long id;

    @Getter
    private String name;

    @Setter
    @Getter
    private Integer workspaceId;

    @Setter
    @Getter
    private Date createdAt;

    @Getter
    @Setter
    private Date updatedAt;

    public Board(Long id, String name, Integer workspaceId, Date createdAt) {
        this.id = id;
        this.name = name;
        this.workspaceId = workspaceId;
        this.createdAt = createdAt;
    }

}
