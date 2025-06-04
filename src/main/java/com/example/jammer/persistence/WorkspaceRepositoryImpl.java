package com.example.jammer.persistence;

import com.example.jammer.domain.model.User;
import com.example.jammer.domain.model.Workspace;
import com.example.jammer.domain.repository.WorkspaceRepository;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@Repository
public class WorkspaceRepositoryImpl implements WorkspaceRepository {
    private final DataSource dataSource;

    public WorkspaceRepositoryImpl(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public Workspace findByUserId(int userId) {
        String sql = """
                SELECT [Id], [UserId], [Name] from [Workspace].[Workspaces]
                    WHERE [UserId] = ?
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                List<Workspace> workspaces = new ArrayList<>();
                while (rs.next()) {
                    workspaces.add(mapRow(rs));
                }
                if (workspaces.isEmpty()) {
                    // If no workspace exists, create one
                    return save(userId);
                }
                return workspaces.getFirst();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private Workspace mapRow(ResultSet rs) throws SQLException {
        Workspace workspace = new Workspace();
        workspace.setId(rs.getInt("Id"));
        workspace.setUserId(rs.getInt("UserId"));
        workspace.setName(rs.getString("Name"));
        return workspace;
    }

    @Override
    public Workspace save(int userId) {
        String sql = """
                INSERT INTO [Workspace].[Workspaces] ([UserId], [Name])
                VALUES (?, ?)
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setString(2, "My Workspace"); // Default workspace name

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating workspace failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    Workspace workspace = new Workspace();
                    workspace.setId(generatedKeys.getInt(1));
                    workspace.setUserId(userId);
                    workspace.setName("My Workspace");
                    return workspace;
                } else {
                    throw new SQLException("Creating workspace failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
