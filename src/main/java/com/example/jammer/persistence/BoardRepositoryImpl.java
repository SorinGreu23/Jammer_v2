package com.example.jammer.persistence;

import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class BoardRepositoryImpl implements BoardRepository {
    private final DataSource dataSource;

    public BoardRepositoryImpl(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public List<Board> findByUserId(int userId) {
        String sql = """
            SELECT b.[Id], b.[Name], b.[WorkspaceId], b.[CreatedAt], b.[UpdatedAt]
              FROM [Workspace].[Boards] b
             INNER JOIN [Workspace].[Workspaces] w ON b.[WorkspaceId] = w.[Id]
             WHERE w.[UserId] = ?
            """;

        List<Board> boards = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    boards.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding boards by user ID", e);
        }
        return boards;
    }

    @Override
    public Board save(Board board) {
        if (board.getId() == null) {
            return insert(board);
        } else {
            return update(board);
        }
    }

    private Board insert(Board board) {
        String sql = """
            INSERT INTO [Workspace].[Boards]
                ([WorkspaceId], [Name], [CreatedAt])
            VALUES (?, ?, ?);
            """;
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, board.getWorkspaceId());
            ps.setString(2, board.getName());
            ps.setDate(3, (board.getCreatedAt() != null
                    ? (Date) board.getCreatedAt()
                    : Date.valueOf(LocalDate.now())));

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Creating board failed, no rows affected.");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    long newId = keys.getLong(1);
                    return new Board(newId, board.getName(), board.getWorkspaceId(), board.getCreatedAt());
                } else {
                    throw new RuntimeException("Creating board failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error inserting board", e);
        }
    }

    private Board update(Board board) {
        String sql = """
            UPDATE [Workspace].[Boards]
               SET [Name] = ?,
                   [UpdatedAt] = ?
             WHERE [Id] = ?
            """;
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, board.getName());
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            ps.setLong(3, board.getId());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Updating board failed, no rows affected.");
            }
            board.setUpdatedAt(Date.valueOf(LocalDate.now()));
            return board;
        } catch (SQLException e) {
            throw new RuntimeException("Error updating board", e);
        }
    }

    private Board mapRow(ResultSet rs) throws SQLException {
        Board board = new Board(
                rs.getLong("Id"),
                rs.getString("Name"),
                rs.getInt("WorkspaceId"),
                rs.getDate("CreatedAt")
        );
        Date updatedAt = rs.getDate("UpdatedAt");
        if (updatedAt != null) {
            board.setUpdatedAt(updatedAt);
        }
        return board;
    }
}