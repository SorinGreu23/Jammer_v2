package com.example.jammer.application.task;

import com.example.jammer.api.dtos.task.TaskResponse;
import com.example.jammer.domain.model.Task;
import com.example.jammer.domain.repository.TaskRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class GetTaskByBoardUseCase {
    private final TaskRepository taskRepository;

    public GetTaskByBoardUseCase(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public List<TaskResponse> execute(Integer boardId) {
        List<Task> tasks = taskRepository.findByBoardId(boardId);
        return tasks.stream().map(task -> {
            TaskResponse resp = new TaskResponse();
            resp.setId(task.getId());
            resp.setBoardId(task.getBoardId());
            resp.setName(task.getName());
            resp.setDescription(task.getDescription());
            resp.setStatus(task.getStatus());
            resp.setCreatedAt(task.getCreatedAt());
            resp.setUpdatedAt(task.getUpdatedAt());
            resp.setUserId(task.getUserId());
            return resp;
        }).collect(Collectors.toList());
    }
}