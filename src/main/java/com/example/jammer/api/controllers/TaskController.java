package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.task.CreateTaskRequest;
import com.example.jammer.api.dtos.task.TaskResponse;
import com.example.jammer.api.dtos.task.UpdateTaskRequest;
import com.example.jammer.api.exception.TaskNotFoundException;
import com.example.jammer.api.exception.TaskDeletionNotAllowedException;
import com.example.jammer.application.task.CreateTaskUseCase;
import com.example.jammer.application.task.DeleteTaskUseCase;
import com.example.jammer.application.task.GetTaskByBoardUseCase;
import com.example.jammer.application.task.GetTaskByIdUseCase;
import com.example.jammer.application.task.UpdateTaskUseCase;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:4200", allowCredentials = "true")
public class TaskController {

    private final GetTaskByBoardUseCase getTaskByBoardUseCase;
    private final GetTaskByIdUseCase getTaskByIdUseCase;
    private final CreateTaskUseCase createTaskUseCase;
    private final UpdateTaskUseCase updateTaskUseCase;
    private final DeleteTaskUseCase deleteTaskUseCase;

    public TaskController(
            GetTaskByBoardUseCase getTaskByBoardUseCase,
            GetTaskByIdUseCase getTaskByIdUseCase,
            CreateTaskUseCase createTaskUseCase,
            UpdateTaskUseCase updateTaskUseCase,
            DeleteTaskUseCase deleteTaskUseCase) {
        this.getTaskByBoardUseCase = getTaskByBoardUseCase;
        this.getTaskByIdUseCase = getTaskByIdUseCase;
        this.createTaskUseCase = createTaskUseCase;
        this.updateTaskUseCase = updateTaskUseCase;
        this.deleteTaskUseCase = deleteTaskUseCase;
    }

    @GetMapping("/boards/{boardId}/tasks")
    public ResponseEntity<List<TaskResponse>> getTasksByBoardId(@PathVariable Integer boardId) {
        try {
            List<TaskResponse> tasks = getTaskByBoardUseCase.execute(boardId);
            return ResponseEntity.ok(tasks);
        } catch (Exception e) {
            throw new RuntimeException("Failed to retrieve tasks for board ID: " + boardId, e);
        }
    }

    @GetMapping("/tasks/{id}")
    public ResponseEntity<TaskResponse> getTaskById(@PathVariable Integer id) {
        try {
            TaskResponse task = getTaskByIdUseCase.execute(id);
            if (task == null) {
                throw new TaskNotFoundException("Task with ID " + id + " not found");
            }
            return ResponseEntity.ok(task);
        } catch (TaskNotFoundException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Failed to retrieve task with ID: " + id, e);
        }
    }

    @PostMapping("/boards/{boardId}/tasks")
    public ResponseEntity<TaskResponse> createTask(
            @PathVariable Integer boardId,
            @RequestBody CreateTaskRequest request) {
        try {
            if (request.getName() == null || request.getName().trim().isEmpty()) {
                throw new IllegalArgumentException("Task name is required and cannot be empty");
            }
            
            request.setBoardId(boardId);
            TaskResponse created = createTaskUseCase.execute(request);
            return new ResponseEntity<>(created, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Failed to create task: " + e.getMessage(), e);
        }
    }

    @PutMapping("/tasks/{id}")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable Integer id,
            @RequestBody UpdateTaskRequest request) {
        try {
            if (request.getName() == null || request.getName().trim().isEmpty()) {
                throw new IllegalArgumentException("Task name is required and cannot be empty");
            }
            
            TaskResponse updated = updateTaskUseCase.execute(id, request);
            if (updated == null) {
                throw new TaskNotFoundException("Task with ID " + id + " not found");
            }
            return ResponseEntity.ok(updated);
        } catch (TaskNotFoundException | IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Failed to update task with ID " + id + ": " + e.getMessage(), e);
        }
    }

    @DeleteMapping("/tasks/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Integer id) {
        try {
            // Check if task exists and get its status
            TaskResponse task = getTaskByIdUseCase.execute(id);
            if (task == null) {
                throw new TaskNotFoundException("Task with ID " + id + " not found");
            }
            
            // Check if task is in DONE status (not allowed to delete)
            if ("DONE".equalsIgnoreCase(task.getStatus())) {
                throw new TaskDeletionNotAllowedException("Cannot delete completed tasks. Task '" + task.getName() + "' is marked as DONE.");
            }
            
            deleteTaskUseCase.execute(id);
            return ResponseEntity.noContent().build();
        } catch (TaskNotFoundException | TaskDeletionNotAllowedException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete task with ID " + id + ": " + e.getMessage(), e);
        }
    }
}