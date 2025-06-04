package com.example.jammer.application.board;

import com.example.jammer.api.dtos.board.InviteUserRequest;
import com.example.jammer.api.dtos.board.InviteUserResponse;
import com.example.jammer.domain.repository.BoardMemberRepository;
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.stereotype.Service;

@Service
public class InviteUserToBoardUseCase {
    private final BoardMemberRepository boardMemberRepository;
    private final BoardRepository boardRepository;

    public InviteUserToBoardUseCase(BoardMemberRepository boardMemberRepository, 
                                   BoardRepository boardRepository) {
        this.boardMemberRepository = boardMemberRepository;
        this.boardRepository = boardRepository;
    }

    public InviteUserResponse execute(InviteUserRequest request, Integer inviterId) {
        // Verify board exists
        if (boardRepository.findById(request.getBoardId().longValue()) == null) {
            throw new RuntimeException("Board not found");
        }

        // Check if inviter has permission (board owner or admin)
        // For now, we'll allow any authenticated user to invite
        // You can add more sophisticated permission checking here

        return boardMemberRepository.inviteUserToBoard(
            request.getUsernameOrEmail(), 
            request.getBoardId(), 
            inviterId
        );
    }
} 