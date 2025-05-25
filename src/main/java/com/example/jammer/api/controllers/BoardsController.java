package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.BoardDto;
import com.example.jammer.application.BoardsManager;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.List;

public class BoardsController {
    private final BoardsManager boardsManager;

    public BoardsController(BoardsManager boardsManager) {
        this.boardsManager = boardsManager;
    }

    @GetMapping
    public List<BoardDto> getAll() {
        return boardsManager.listBoards().stream()
                .map(BoardDto::fromDomain)
                .toList();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BoardDto create(@RequestBody BoardDto dto) {
        var board = dto.toDomain();
        var created = boardsManager.createBoard(board);
        return BoardDto.fromDomain(created);
    }
}
