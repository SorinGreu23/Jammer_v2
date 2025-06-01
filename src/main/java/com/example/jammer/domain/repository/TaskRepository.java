package com.example.jammer.domain.repository;

import com.example.jammer.domain.model.Task;
import java.util.List;

public interface TaskRepository {
    Task save(Task task);
    List<Task> findByBoardId(Integer boardId);
    Task findById(Integer id);
    Task update(Task task);
    void delete(Integer id);
    String getDescription(Integer id);
    void setDescription(Integer id, String description);
}