package com.example.jammer.api.dtos.board;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoardStatisticsResponse {
    private Integer boardId;
    private String boardName;
    private Integer totalTasks;
    private Integer completedTasks;
    private Double completionPercentage;

    public BoardStatisticsResponse(Integer boardId, String boardName, Integer totalTasks, Integer completedTasks, Double completionPercentage) {
        this.boardId = boardId;
        this.boardName = boardName;
        this.totalTasks = totalTasks;
        this.completedTasks = completedTasks;
        this.completionPercentage = completionPercentage;
    }
} 