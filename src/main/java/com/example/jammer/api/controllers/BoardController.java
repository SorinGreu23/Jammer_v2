package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.board.CreateBoardRequest;
import com.example.jammer.api.dtos.board.CreateBoardResponse;
import com.example.jammer.application.board.CreateBoardUseCase;
import com.example.jammer.application.board.GetBoardsByUserUseCase;
import com.example.jammer.domain.model.Board;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/boards")
public class BoardController {

    private final CreateBoardUseCase createBoardUseCase;
    private final GetBoardsByUserUseCase getBoardsByUserUseCase;

    public BoardController(CreateBoardUseCase createBoardUseCase, GetBoardsByUserUseCase getBoardsByUserUseCase) {
        this.createBoardUseCase = createBoardUseCase;
        this.getBoardsByUserUseCase = getBoardsByUserUseCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CreateBoardResponse createBoard(@RequestBody CreateBoardRequest request) {
        return createBoardUseCase.execute(request);
    }

    @GetMapping("/user/{userId}")
    @ResponseStatus(HttpStatus.OK)
    public List<Board> getBoardsByUserId(@PathVariable int userId) {
        return getBoardsByUserUseCase.execute(userId);
    }
}
