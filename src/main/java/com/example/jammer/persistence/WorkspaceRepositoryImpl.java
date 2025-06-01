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
        return null;
    }
}
