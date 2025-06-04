package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.board.CreateBoardRequest;
import com.example.jammer.api.dtos.board.CreateBoardResponse;
import com.example.jammer.api.dtos.board.InviteUserRequest;
import com.example.jammer.api.dtos.board.InviteUserResponse;
import com.example.jammer.application.board.CreateBoardUseCase;
import com.example.jammer.application.board.GetBoardsByUserUseCase;
import com.example.jammer.application.board.UpdateBoardUseCase;
import com.example.jammer.application.board.DeleteBoardUseCase;
import com.example.jammer.application.board.GetBoardStatisticsUseCase;
import com.example.jammer.application.board.InviteUserToBoardUseCase;
import com.example.jammer.application.board.GetBoardMembersUseCase;
import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.model.BoardMember;
import com.example.jammer.api.dtos.board.BoardStatisticsResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/boards")
public class BoardController {

    private final CreateBoardUseCase createBoardUseCase;
    private final GetBoardsByUserUseCase getBoardsByUserUseCase;
    private final UpdateBoardUseCase updateBoardUseCase;
    private final DeleteBoardUseCase deleteBoardUseCase;
    private final GetBoardStatisticsUseCase getBoardStatisticsUseCase;
    private final InviteUserToBoardUseCase inviteUserToBoardUseCase;
    private final GetBoardMembersUseCase getBoardMembersUseCase;

    public BoardController(
            CreateBoardUseCase createBoardUseCase,
            GetBoardsByUserUseCase getBoardsByUserUseCase,
            UpdateBoardUseCase updateBoardUseCase,
            DeleteBoardUseCase deleteBoardUseCase,
            GetBoardStatisticsUseCase getBoardStatisticsUseCase,
            InviteUserToBoardUseCase inviteUserToBoardUseCase,
            GetBoardMembersUseCase getBoardMembersUseCase
    ) {
        this.createBoardUseCase = createBoardUseCase;
        this.getBoardsByUserUseCase = getBoardsByUserUseCase;
        this.updateBoardUseCase = updateBoardUseCase;
        this.deleteBoardUseCase = deleteBoardUseCase;
        this.getBoardStatisticsUseCase = getBoardStatisticsUseCase;
        this.inviteUserToBoardUseCase = inviteUserToBoardUseCase;
        this.getBoardMembersUseCase = getBoardMembersUseCase;
    }

    @DeleteMapping("/{boardId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBoard(@PathVariable Long boardId) {
        deleteBoardUseCase.execute(boardId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CreateBoardResponse createBoard(@RequestBody CreateBoardRequest request) {
        return createBoardUseCase.execute(request);
    }

    @PutMapping("/{boardId}")
    public ResponseEntity<Board> updateBoard(@PathVariable Long boardId, @RequestBody String newName) {
        Board updated = updateBoardUseCase.execute(boardId, newName);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/user/{userId}")
    @ResponseStatus(HttpStatus.OK)
    public List<Board> getBoardsByUserId(@PathVariable int userId) {
        return getBoardsByUserUseCase.execute(userId);
    }

    @GetMapping("/user/{userId}/statistics")
    @ResponseStatus(HttpStatus.OK)
    public List<BoardStatisticsResponse> getBoardStatistics(@PathVariable int userId) {
        return getBoardStatisticsUseCase.execute(userId);
    }

    // Board collaboration endpoints
    @PostMapping("/{boardId}/invite")
    @ResponseStatus(HttpStatus.OK)
    public InviteUserResponse inviteUserToBoard(
            @PathVariable Integer boardId,
            @RequestBody InviteUserRequest request,
            @RequestHeader("X-User-Id") Integer userId) {
        request.setBoardId(boardId);
        return inviteUserToBoardUseCase.execute(request, userId);
    }

    @GetMapping("/{boardId}/members")
    @ResponseStatus(HttpStatus.OK)
    public List<BoardMember> getBoardMembers(@PathVariable Integer boardId) {
        return getBoardMembersUseCase.execute(boardId);
    }
}
