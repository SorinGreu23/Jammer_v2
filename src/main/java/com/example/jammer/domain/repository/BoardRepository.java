package com.example.jammer.domain.repository;

import com.example.jammer.domain.Board;

import java.util.List;

public interface BoardRepository {
    List<Board> getBoards(int userId);
    Board createBoard(int workspaceId, String name);
}
