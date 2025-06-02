package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class UpdateBoardResponse {
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
    private Date updatedAt;

    public UpdateBoardResponse(Long id, String name, Integer workspaceId, Date updatedAt) {
        this.id = id;
        this.name = name;
        this.workspaceId = workspaceId;
        this.updatedAt = updatedAt;
    }
}