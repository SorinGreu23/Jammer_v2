package com.example.jammer.api.dtos;

import com.example.jammer.domain.Boards.Board;

public class BoardDto {
    public Long id;
    public String name;
    public Long ownerId;

    public static BoardDto fromDomain(Board board) {
        BoardDto dto = new BoardDto();
        dto.id = board.getId();
        dto.name = board.getName();
        dto.ownerId = board.getOwnerId();
    }

    public Board toDomain() {
        return new Board(id, name, ownerId);
    }
}
