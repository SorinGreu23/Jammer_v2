package com.example.jammer.application.board;

import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DeleteBoardUseCase {
    private final BoardRepository boardRepository;

    public DeleteBoardUseCase(BoardRepository boardRepository) {
        this.boardRepository = boardRepository;
    }

    @Transactional
    public void execute(Long boardId) {
        boardRepository.deleteById(boardId);
    }
}