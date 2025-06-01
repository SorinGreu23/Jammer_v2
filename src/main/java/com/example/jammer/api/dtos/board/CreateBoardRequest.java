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

    public CreateBoardRequest(String name, Integer userId) {
        this.name = name;
        this.userId = userId;
    }
}
