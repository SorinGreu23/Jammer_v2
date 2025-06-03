package com.example.jammer.application.task;

import com.example.jammer.api.dtos.task.TaskResponse;
import com.example.jammer.api.dtos.task.UpdateTaskRequest;
import com.example.jammer.domain.model.Task;
import com.example.jammer.domain.repository.TaskRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

@Service
public class UpdateTaskUseCase {
    private final TaskRepository taskRepository;

    public UpdateTaskUseCase(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    @Transactional
    public TaskResponse execute(Integer id, UpdateTaskRequest request) {
        Task task = taskRepository.findById(id);
        if (task == null) {
            throw new IllegalArgumentException("Task not found");
        }
        task.setName(request.getName());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus());
        task.setUpdatedAt(new Date());
        Task updated = taskRepository.update(task);

        TaskResponse resp = new TaskResponse();
        resp.setId(updated.getId());
        resp.setBoardId(updated.getBoardId());
        resp.setName(updated.getName());
        resp.setDescription(updated.getDescription());
        resp.setStatus(updated.getStatus());
        resp.setCreatedAt(updated.getCreatedAt());
        resp.setUpdatedAt(updated.getUpdatedAt());
        resp.setUserId(updated.getUserId());
        return resp;
    }
}