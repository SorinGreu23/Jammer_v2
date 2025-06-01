package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.task.CreateTaskRequest;
import com.example.jammer.api.dtos.task.TaskResponse;
import com.example.jammer.api.dtos.task.UpdateTaskRequest;
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
        List<TaskResponse> tasks = getTaskByBoardUseCase.execute(boardId);
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/tasks/{id}")
    public ResponseEntity<TaskResponse> getTaskById(@PathVariable Integer id) {
        TaskResponse task = getTaskByIdUseCase.execute(id);
        return ResponseEntity.ok(task);
    }

    @PostMapping("/boards/{boardId}/tasks")
    public ResponseEntity<TaskResponse> createTask(
            @PathVariable Integer boardId,
            @RequestBody CreateTaskRequest request) {
        request.setBoardId(boardId);
        TaskResponse created = createTaskUseCase.execute(request);
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @PutMapping("/tasks/{id}")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable Integer id,
            @RequestBody UpdateTaskRequest request) {
        TaskResponse updated = updateTaskUseCase.execute(id, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/tasks/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Integer id) {
        deleteTaskUseCase.execute(id);
        return ResponseEntity.noContent().build();
    }
}