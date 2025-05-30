package com.example.jammer.domain.repository;

import com.example.jammer.domain.Workspace;

import java.util.List;

public interface WorkspaceRepository {
    List<Workspace> getWorkspaceByUserId(int userId);
    Workspace createWorkspace(int userId);
}
