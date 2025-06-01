package com.example.jammer.application.task;

import com.example.jammer.api.dtos.task.TaskResponse;
import com.example.jammer.domain.model.Task;
import com.example.jammer.domain.repository.TaskRepository;
import org.springframework.stereotype.Service;

@Service
public class GetTaskByIdUseCase {
    private final TaskRepository taskRepository;

    public GetTaskByIdUseCase(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public TaskResponse execute(Integer id) {
        Task task = taskRepository.findById(id);
        if (task == null) {
            throw new IllegalArgumentException("Task not found");
        }

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
    }
}