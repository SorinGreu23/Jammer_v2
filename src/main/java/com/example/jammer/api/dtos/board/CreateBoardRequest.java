package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class CreateBoardRequest {
    @Getter
    @Setter
    private String name;

    @Getter
    @Setter
    private Integer userId;

    @Getter
    @Setter
    private String username;

    public CreateBoardRequest() {}

    public CreateBoardRequest(String name, Integer userId, String username) {
        this.name = name;
        this.userId = userId;
        this.username = username;
    }
}
