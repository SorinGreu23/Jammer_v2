package com.example.jammer.application.board;

import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UpdateBoardUseCase {
    private final BoardRepository boardRepository;

    public UpdateBoardUseCase(BoardRepository boardRepository) {
        this.boardRepository = boardRepository;
    }

    @Transactional
    public Board execute(Long boardId, String newName) {
        Board board = boardRepository.findById(boardId);
        if (board == null) {
            throw new IllegalArgumentException("Board not found");
        }
        board.setName(newName);
        return boardRepository.update(board);
    }
}