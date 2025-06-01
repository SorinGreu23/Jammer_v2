package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class CreateBoardResponse {
    @Getter
    @Setter
    private Long id;

    @Getter
    @Setter
    private String name;

    @Getter
    @Setter
    private Integer workspaceId;

    @Getter
    @Setter
    private Date createdAt;

    public CreateBoardResponse(Long id, String name, Integer workspaceId, Date createdAt) {
        this.id = id;
        this.name = name;
        this.workspaceId = workspaceId;
        this.createdAt = createdAt;
    }
}