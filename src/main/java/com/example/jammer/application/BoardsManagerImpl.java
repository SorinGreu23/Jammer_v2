package com.example.jammer.application;

import com.example.jammer.domain.Boards.Board;
import com.example.jammer.domain.repository.BoardRepository;

import java.util.List;

public class BoardsManagerImpl implements BoardsManager {
    private final BoardRepository boardRepository;

    public BoardsManagerImpl(BoardRepository boardRepository) {
        this.boardRepository = boardRepository;
    }

    @Override
    public List<Board> listBoards() {
        return boardRepository.getAll();
    }

    @Override
    public Board createBoard(Board board) {
        boardRepository.save(board);
        return board;
    }
}
