package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class UpdateBoardRequest {
    @Getter
    @Setter
    private String name;

    public UpdateBoardRequest() {}

    public UpdateBoardRequest(String name) {
        this.name = name;
    }
}