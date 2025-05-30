package com.example.jammer.domain.repository;

import com.example.jammer.domain.model.Workspace;

import java.util.List;

public interface WorkspaceRepository {
    List<Workspace> findByUserId(int userId);
    Workspace save(int userId);
}
