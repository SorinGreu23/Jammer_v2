package com.example.jammer.application.board;

import com.example.jammer.api.dtos.board.AcceptInvitationResponse;
import com.example.jammer.domain.repository.BoardMemberRepository;
import org.springframework.stereotype.Service;

@Service
public class AcceptBoardInvitationUseCase {
    private final BoardMemberRepository boardMemberRepository;

    public AcceptBoardInvitationUseCase(BoardMemberRepository boardMemberRepository) {
        this.boardMemberRepository = boardMemberRepository;
    }

    public AcceptInvitationResponse execute(String token, Integer userId) {
        try {
            Integer boardId = boardMemberRepository.acceptBoardInvitation(token, userId);
            return new AcceptInvitationResponse(boardId, "Successfully joined the board");
        } catch (RuntimeException e) {
            throw new RuntimeException(e.getMessage());
        }
    }
} 