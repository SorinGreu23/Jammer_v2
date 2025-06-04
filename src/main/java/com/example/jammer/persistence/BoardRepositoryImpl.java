package com.example.jammer.persistence;

import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.repository.BoardRepository;
import com.example.jammer.api.dtos.board.BoardStatisticsResponse;
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
            SELECT DISTINCT b.[Id], b.[Name], b.[WorkspaceId], b.[CreatedAt], b.[UpdatedAt]
            FROM [Workspace].[Boards] b
            LEFT JOIN [Workspace].[Workspaces] w ON b.[WorkspaceId] = w.[Id]
            LEFT JOIN [Workspace].[BoardMembers] bm ON b.[Id] = bm.[BoardId]
            WHERE w.[UserId] = ? 
               OR (bm.[UserId] = ? AND bm.[Status] = 'ACCEPTED')
            """;

        List<Board> boards = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, userId);
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

    @Override
    public void deleteById(Long boardId) {
        String sql = "DELETE FROM [Workspace].[Boards] WHERE [Id] = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, boardId);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Deleting board failed, no rows affected.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error deleting board", e);
        }
    }

    @Override
    public Board findById(Long boardId) {
        String sql = "SELECT [Id], [Name], [WorkspaceId], [CreatedAt], [UpdatedAt] FROM [Workspace].[Boards] WHERE [Id] = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, boardId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding board by ID", e);
        }
        return null;
    }

    @Override
    public List<BoardStatisticsResponse> getBoardStatistics(int userId) {
        String sql = "{CALL [Workspace].[GetUserBoardStatistics](?)}";
        List<BoardStatisticsResponse> statistics = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, userId);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    statistics.add(new BoardStatisticsResponse(
                            rs.getInt("BoardId"),
                            rs.getString("BoardName"),
                            rs.getInt("TotalTasks"),
                            rs.getInt("CompletedTasks"),
                            rs.getDouble("CompletionPercentage")
                    ));
                }
            }
            return statistics;
        } catch (SQLException e) {
            throw new RuntimeException("Error getting board statistics", e);
        }
    }

    @Override
    public int countBoardsSharedWithUser(int userId) {
        String sql = """
            SELECT COUNT(DISTINCT b.[Id])
            FROM [Workspace].[Boards] b
            LEFT JOIN [Workspace].[BoardMembers] bm ON b.[Id] = bm.[BoardId] AND bm.[UserId] = ? AND bm.[Status] = 'ACCEPTED'
            LEFT JOIN [Workspace].[Workspaces] userWorkspace ON userWorkspace.[UserId] = ?
            WHERE bm.[UserId] IS NOT NULL 
            AND b.[WorkspaceId] != userWorkspace.[Id]
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error counting boards shared with user", e);
        }
        return 0;
    }

    @Override
    public int countBoardsSharedByUser(int userId) {
        String sql = """
            SELECT COUNT(DISTINCT b.[Id])
            FROM [Workspace].[Boards] b
            INNER JOIN [Workspace].[Workspaces] w ON b.[WorkspaceId] = w.[Id] AND w.[UserId] = ?
            INNER JOIN [Workspace].[BoardMembers] bm ON b.[Id] = bm.[BoardId] AND bm.[UserId] != ? AND bm.[Status] = 'ACCEPTED'
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error counting boards shared by user", e);
        }
        return 0;
    }

    @Override
    public int countBoardsOwnedByUser(int userId) {
        String sql = """
            SELECT COUNT(b.[Id])
            FROM [Workspace].[Boards] b
            INNER JOIN [Workspace].[Workspaces] w ON b.[WorkspaceId] = w.[Id]
            WHERE w.[UserId] = ?
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error counting boards owned by user", e);
        }
        return 0;
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

    public Board update(Board board) {
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