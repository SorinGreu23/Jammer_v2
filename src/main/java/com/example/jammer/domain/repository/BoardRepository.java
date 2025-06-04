package com.example.jammer.domain.repository;

import com.example.jammer.domain.model.Board;
import com.example.jammer.api.dtos.board.BoardStatisticsResponse;

import java.util.List;

public interface BoardRepository {
    List<Board> findByUserId(int userId);
    Board save(Board board);
    void deleteById(Long boardId);
    Board update(Board board);
    Board findById(Long boardId);
    List<BoardStatisticsResponse> getBoardStatistics(int userId);
    int countBoardsSharedWithUser(int userId);
    int countBoardsSharedByUser(int userId);
    int countBoardsOwnedByUser(int userId);
}
