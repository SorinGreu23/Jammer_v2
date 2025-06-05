package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.board.CreateBoardRequest;
import com.example.jammer.api.dtos.board.CreateBoardResponse;
import com.example.jammer.api.dtos.board.InviteUserRequest;
import com.example.jammer.api.dtos.board.InviteUserResponse;
import com.example.jammer.api.dtos.board.AcceptInvitationRequest;
import com.example.jammer.api.dtos.board.AcceptInvitationResponse;
import com.example.jammer.application.board.CreateBoardUseCase;
import com.example.jammer.application.board.GetBoardsByUserUseCase;
import com.example.jammer.application.board.UpdateBoardUseCase;
import com.example.jammer.application.board.DeleteBoardUseCase;
import com.example.jammer.application.board.GetBoardStatisticsUseCase;
import com.example.jammer.application.board.InviteUserToBoardUseCase;
import com.example.jammer.application.board.GetBoardMembersUseCase;
import com.example.jammer.application.board.AcceptBoardInvitationUseCase;
import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.model.BoardMember;
import com.example.jammer.domain.repository.BoardMemberRepository;
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
    private final AcceptBoardInvitationUseCase acceptBoardInvitationUseCase;
    private final BoardMemberRepository boardMemberRepository;

    public BoardController(
            CreateBoardUseCase createBoardUseCase,
            GetBoardsByUserUseCase getBoardsByUserUseCase,
            UpdateBoardUseCase updateBoardUseCase,
            DeleteBoardUseCase deleteBoardUseCase,
            GetBoardStatisticsUseCase getBoardStatisticsUseCase,
            InviteUserToBoardUseCase inviteUserToBoardUseCase,
            GetBoardMembersUseCase getBoardMembersUseCase,
            AcceptBoardInvitationUseCase acceptBoardInvitationUseCase,
            BoardMemberRepository boardMemberRepository) {
        this.createBoardUseCase = createBoardUseCase;
        this.getBoardsByUserUseCase = getBoardsByUserUseCase;
        this.updateBoardUseCase = updateBoardUseCase;
        this.deleteBoardUseCase = deleteBoardUseCase;
        this.getBoardStatisticsUseCase = getBoardStatisticsUseCase;
        this.inviteUserToBoardUseCase = inviteUserToBoardUseCase;
        this.getBoardMembersUseCase = getBoardMembersUseCase;
        this.acceptBoardInvitationUseCase = acceptBoardInvitationUseCase;
        this.boardMemberRepository = boardMemberRepository;
    }

    @DeleteMapping("/{boardId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBoard(@PathVariable Long boardId, @RequestHeader("X-User-Id") Integer userId) {
        deleteBoardUseCase.execute(boardId, userId);
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
    public ResponseEntity<List<Board>> getBoardsByUserId(
            @PathVariable int userId,
            @RequestHeader("X-User-Id") Integer xUserId) {
        // Verify that the requesting user is the same as the target user
        if (userId != xUserId) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        return ResponseEntity.ok(getBoardsByUserUseCase.execute(userId));
    }

    @GetMapping("/user/{userId}/statistics")
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<List<BoardStatisticsResponse>> getBoardStatistics(
            @PathVariable int userId,
            @RequestHeader("X-User-Id") Integer xUserId) {
        // Verify that the requesting user is the same as the target user
        if (userId != xUserId) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        return ResponseEntity.ok(getBoardStatisticsUseCase.execute(userId));
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

    @PostMapping("/join")
    @ResponseStatus(HttpStatus.OK)
    public AcceptInvitationResponse acceptBoardInvitation(
            @RequestBody AcceptInvitationRequest request,
            @RequestHeader("X-User-Id") Integer userId) {
        return acceptBoardInvitationUseCase.execute(request.getToken(), userId);
    }

    @DeleteMapping("/{boardId}/members/{userId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeBoardMember(
            @PathVariable Integer boardId, 
            @PathVariable Integer userId,
            @RequestHeader("X-User-Id") Integer currentUserId) {
        // Check if current user is a board admin
        if (!boardMemberRepository.isUserBoardAdmin(currentUserId, boardId)) {
            throw new RuntimeException("Only board admins can remove members");
        }
        
        // Check if trying to remove self
        if (userId.equals(currentUserId)) {
            throw new RuntimeException("Cannot remove yourself. Use the leave board endpoint instead.");
        }
        
        boardMemberRepository.removeBoardMember(userId, boardId);
    }

    @DeleteMapping("/{boardId}/leave")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void leaveBoard(@PathVariable Integer boardId, @RequestHeader("X-User-Id") Integer userId) {
        // Check if user is a member of the board
        if (!boardMemberRepository.isUserBoardMember(userId, boardId)) {
            throw new RuntimeException("User is not a member of this board");
        }
        
        // Check if user is not the owner (admin)
        if (boardMemberRepository.isUserBoardAdmin(userId, boardId)) {
            throw new RuntimeException("Board owner cannot leave the board. Please delete the board instead.");
        }
        
        boardMemberRepository.removeBoardMember(userId, boardId);
    }
}
