package com.example.jammer.application;

import com.example.jammer.domain.Boards.Board;

import java.util.List;

public interface BoardsManager {
    List<Board> listBoards();
    Board createBoard(Board board);
}
