package com.example.jammer.application.board;

import com.example.jammer.domain.model.BoardMember;
import com.example.jammer.domain.repository.BoardMemberRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetBoardMembersUseCase {
    private final BoardMemberRepository boardMemberRepository;

    public GetBoardMembersUseCase(BoardMemberRepository boardMemberRepository) {
        this.boardMemberRepository = boardMemberRepository;
    }

    public List<BoardMember> execute(Integer boardId) {
        return boardMemberRepository.getBoardMembers(boardId);
    }
} 