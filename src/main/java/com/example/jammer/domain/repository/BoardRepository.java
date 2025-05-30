package com.example.jammer.domain.repository;

import com.example.jammer.domain.model.Board;

import java.util.List;

public interface BoardRepository {
    List<Board> findByUserId(int userId);
    Board save(Board board);
}
