package com.example.jammer.api.controllers;

import com.example.jammer.domain.model.Workspace;
import com.example.jammer.domain.repository.WorkspaceRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/workspaces")
public class WorkspaceController {
    private final WorkspaceRepository workspaceRepository;

    public WorkspaceController(WorkspaceRepository workspaceRepository) {
        this.workspaceRepository = workspaceRepository;
    }

    @GetMapping("/user/{userId}")
    @ResponseStatus(HttpStatus.OK)
    public ResponseEntity<Workspace> getWorkspaceByUserId(
            @PathVariable int userId,
            @RequestHeader("X-User-Id") Integer xUserId) {
        // Verify that the requesting user is the same as the target user
        if (userId != xUserId) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        Workspace workspace = workspaceRepository.findByUserId(userId);
        return ResponseEntity.ok(workspace);
    }
} 