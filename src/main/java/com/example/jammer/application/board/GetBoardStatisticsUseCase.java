package com.example.jammer.application.board;

import com.example.jammer.api.dtos.board.BoardStatisticsResponse;
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetBoardStatisticsUseCase {
    private final BoardRepository boardRepository;

    public GetBoardStatisticsUseCase(BoardRepository boardRepository) {
        this.boardRepository = boardRepository;
    }

    public List<BoardStatisticsResponse> execute(int userId) {
        return boardRepository.getBoardStatistics(userId);
    }
} 