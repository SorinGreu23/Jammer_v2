package com.example.jammer.application.board;

import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetBoardsByUserUseCase {
    private final BoardRepository boardRepository;

    public GetBoardsByUserUseCase(BoardRepository boardRepository) {
        this.boardRepository = boardRepository;
    }

    public List<Board> execute(int userId) {
        return boardRepository.findByUserId(userId);
    }
}