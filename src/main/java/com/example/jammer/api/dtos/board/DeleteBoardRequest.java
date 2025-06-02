package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

public class DeleteBoardRequest {
    @Getter
    @Setter
    private Long boardId;

    public DeleteBoardRequest() {}

    public DeleteBoardRequest(Long boardId) {
        this.boardId = boardId;
    }
}