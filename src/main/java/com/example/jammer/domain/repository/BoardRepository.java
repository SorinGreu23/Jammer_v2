package com.example.jammer.domain.repository;

import com.example.jammer.domain.Boards.Board;

import java.util.List;

public interface BoardRepository {
    List<Board> getAll();
    Board save(Board board);
}
