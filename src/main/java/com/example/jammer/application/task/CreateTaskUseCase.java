package com.example.jammer.application.task;

import com.example.jammer.api.dtos.task.CreateTaskRequest;
import com.example.jammer.api.dtos.task.TaskResponse;
import com.example.jammer.domain.model.Task;
import com.example.jammer.domain.repository.TaskRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

@Service
public class CreateTaskUseCase {
    private final TaskRepository taskRepository;

    public CreateTaskUseCase(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    @Transactional
    public TaskResponse execute(CreateTaskRequest request) {
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Task name is required");
        }
        if (request.getBoardId() == null) {
            throw new IllegalArgumentException("Board ID is required");
        }
        Task task = new Task();
        task.setBoardId(request.getBoardId());
        task.setName(request.getName().trim());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus());
        task.setCreatedAt(new Date());
        task.setUserId(request.getUserId());
        Task saved = taskRepository.save(task);

        TaskResponse resp = new TaskResponse();
        resp.setId(saved.getId());
        resp.setBoardId(saved.getBoardId());
        resp.setName(saved.getName());
        resp.setDescription(saved.getDescription());
        resp.setStatus(saved.getStatus());
        resp.setCreatedAt(saved.getCreatedAt());
        resp.setUpdatedAt(saved.getUpdatedAt());
        resp.setUserId(saved.getUserId());
        return resp;
    }
}