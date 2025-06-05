package com.example.jammer.persistence;

import com.example.jammer.domain.model.Task;
import com.example.jammer.domain.repository.TaskRepository;
import org.springframework.stereotype.Repository;
import com.example.jammer.infrastructure.ConnectionFactory;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class TaskRepositoryImpl implements TaskRepository {

    private final ConnectionFactory connectionFactory;

    public TaskRepositoryImpl(ConnectionFactory connectionFactory) {
        this.connectionFactory = connectionFactory;
    }

    @Override
    public Task save(Task task) {
        if (task.getId() == null || task.getId() <= 0) {
            return insert(task);
        } else {
            return update(task);
        }
    }

    private Task insert(Task task) {
        String sql = """
            INSERT INTO [Workspace].[Tasks]
                ([BoardId], [Name], [Description], [CreatedAt], [Status], [UserId])
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, task.getBoardId());
            ps.setString(2, task.getName());
            ps.setString(3, task.getDescription());
            ps.setDate(4, new java.sql.Date(System.currentTimeMillis()));
            ps.setString(5, task.getStatus());
            ps.setInt(6, task.getUserId());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Creating task failed, no rows affected.");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    task.setId(keys.getInt(1));
                    task.setCreatedAt(new java.sql.Date(System.currentTimeMillis()));
                    return task;
                } else {
                    throw new RuntimeException("Creating task failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 547) { // Foreign key violation
                throw new RuntimeException("Referenced board or user does not exist.", e);
            } else if (e.getErrorCode() == 2627) { // Unique constraint violation
                throw new RuntimeException("Task with these details already exists.", e);
            } else {
                throw new RuntimeException("Error inserting task: " + e.getMessage(), e);
            }
        }
    }

    @Override
    public List<Task> findByBoardId(Integer boardId) {
        String sql = """
            SELECT [Id], [BoardId], [Name], [Description], [CreatedAt], [UpdatedAt], [Status], [UserId]
              FROM [Workspace].[Tasks]
             WHERE [BoardId] = ?
            """;
        List<Task> tasks = new ArrayList<>();
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, boardId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapRow(rs));
                }
            }
            return tasks;
        } catch (SQLException e) {
            throw new RuntimeException("Error loading tasks by board", e);
        }
    }

    @Override
    public Task findById(Integer id) {
        String sql = """
            SELECT [Id], [BoardId], [Name], [Description], [CreatedAt], [UpdatedAt], [Status], [UserId]
              FROM [Workspace].[Tasks]
             WHERE [Id] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
                return null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading task by id", e);
        }
    }

    @Override
    public Task update(Task task) {
        String sql = """
            UPDATE [Workspace].[Tasks]
               SET [Name] = ?,
                   [Description] = ?,
                   [Status] = ?,
                   [UpdatedAt] = ?
             WHERE [Id] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, task.getName());
            ps.setString(2, task.getDescription());
            ps.setString(3, task.getStatus());
            ps.setDate(4, new java.sql.Date(System.currentTimeMillis()));
            ps.setInt(5, task.getId());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Task not found with ID: " + task.getId());
            }
            task.setUpdatedAt(new java.sql.Date(System.currentTimeMillis()));
            return task;
        } catch (SQLException e) {
            if (e.getErrorCode() == 547) { // Foreign key violation
                throw new RuntimeException("Referenced board or user does not exist.", e);
            } else {
                throw new RuntimeException("Error updating task: " + e.getMessage(), e);
            }
        }
    }

    @Override
    public void delete(Integer id) {
        String sql = "DELETE FROM [Workspace].[Tasks] WHERE [Id] = ?";
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Task not found with ID: " + id);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 547) { // Foreign key violation
                throw new RuntimeException("Cannot delete task due to existing references.", e);
            } else {
                throw new RuntimeException("Error deleting task: " + e.getMessage(), e);
            }
        }
    }

    @Override
    public String getDescription(Integer id) {
        String sql = "SELECT [Description] FROM [Workspace].[Tasks] WHERE [Id] = ?";
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Description");
                }
                return null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting task description", e);
        }
    }

    @Override
    public void setDescription(Integer id, String description) {
        String sql = "UPDATE [Workspace].[Tasks] SET [Description] = ?, [UpdatedAt] = ? WHERE [Id] = ?";
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, description);
            ps.setDate(2, new java.sql.Date(System.currentTimeMillis()));
            ps.setInt(3, id);

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Setting task description failed, no rows affected.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error setting task description", e);
        }
    }

    private Task mapRow(ResultSet rs) throws SQLException {
        Task task = new Task();
        task.setId(rs.getInt("Id"));
        task.setBoardId(rs.getInt("BoardId"));
        task.setName(rs.getString("Name"));
        task.setDescription(rs.getString("Description"));
        task.setCreatedAt(rs.getDate("CreatedAt"));
        task.setUpdatedAt(rs.getDate("UpdatedAt"));
        task.setStatus(rs.getString("Status"));
        task.setUserId(rs.getInt("UserId"));
        return task;
    }
}