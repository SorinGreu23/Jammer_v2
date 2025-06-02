package com.example.jammer.api.dtos.board;

public class DeleteBoardResponse {
    private final boolean success;

    public DeleteBoardResponse(boolean success) {
        this.success = success;
    }

    public boolean isSuccess() {
        return success;
    }
}