package com.example.jammer.persistence;

import com.example.jammer.domain.model.BoardMember;
import com.example.jammer.domain.repository.BoardMemberRepository;
import com.example.jammer.api.dtos.board.InviteUserResponse;
import com.example.jammer.infrastructure.email.EmailService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Repository
public class BoardMemberRepositoryImpl implements BoardMemberRepository {
    private final DataSource dataSource;
    private final JdbcTemplate jdbcTemplate;
    private final EmailService emailService;

    public BoardMemberRepositoryImpl(DataSource dataSource, JdbcTemplate jdbcTemplate, EmailService emailService) {
        this.dataSource = dataSource;
        this.jdbcTemplate = jdbcTemplate;
        this.emailService = emailService;
    }

    @Override
    public List<BoardMember> getBoardMembers(Integer boardId) {
        String sql = "EXEC [Workspace].[GetBoardMembers] ?";
        List<BoardMember> members = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, boardId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BoardMember member = new BoardMember(
                        rs.getLong("Id"),
                        rs.getInt("UserId"),
                        rs.getInt("BoardId"),
                        rs.getBoolean("IsAdmin"),
                        rs.getTimestamp("InvitedAt"),
                        rs.getTimestamp("JoinedAt"),
                        rs.getString("Status"),
                        rs.getInt("InvitedBy"),
                        rs.getString("Username"),
                        rs.getString("Email"),
                        rs.getString("FirstName"),
                        rs.getString("LastName"),
                        rs.getString("InviterUsername")
                    );
                    members.add(member);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting board members", e);
        }
        
        return members;
    }

    @Override
    @Transactional
    public InviteUserResponse inviteUserToBoard(String usernameOrEmail, Integer boardId, Integer invitedBy) {
        String invitationToken = UUID.randomUUID().toString();
        String sql = "EXEC [Workspace].[InviteUserToBoard] ?, ?, ?, ?";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, usernameOrEmail);
            ps.setInt(2, boardId);
            ps.setInt(3, invitedBy);
            ps.setString(4, invitationToken);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String invitationType = rs.getString("InvitationType");
                    Integer userId = rs.getObject("UserId") != null ? rs.getInt("UserId") : null;
                    String email = rs.getString("Email");
                    
                    // If it's an email invitation, send the invitation email
                    if ("EMAIL_INVITATION".equals(invitationType)) {
                        // Get board name for the email
                        String boardName = jdbcTemplate.queryForObject(
                            "SELECT [Name] FROM [Workspace].[Boards] WHERE [Id] = ?",
                            String.class,
                            boardId
                        );
                        
                        // Send invitation email
                        emailService.sendBoardInvitation(email, boardName, invitationToken);
                    }
                    
                    String message = invitationType.equals("USER_FOUND") 
                        ? "User has been invited to the board" 
                        : "Invitation email has been sent";
                    
                    return new InviteUserResponse(invitationType, userId, email, message);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error inviting user to board: " + e.getMessage(), e);
        }
        
        throw new RuntimeException("Failed to invite user");
    }

    @Override
    public Integer acceptBoardInvitation(String invitationToken, Integer userId) {
        String sql = "EXEC [Workspace].[AcceptBoardInvitation] ?, ?";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, invitationToken);
            ps.setInt(2, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new RuntimeException("Failed to accept invitation");
                }
                
                return rs.getInt("BoardId");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error accepting board invitation: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean isUserBoardMember(Integer userId, Integer boardId) {
        String sql = """
            SELECT 1 FROM [Workspace].[BoardMembers] 
            WHERE [UserId] = ? AND [BoardId] = ? AND [Status] = 'ACCEPTED'
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, boardId);
            
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error checking board membership", e);
        }
    }

    @Override
    public boolean isUserBoardAdmin(Integer userId, Integer boardId) {
        String sql = """
            SELECT 1 FROM [Workspace].[BoardMembers] 
            WHERE [UserId] = ? AND [BoardId] = ? AND [Status] = 'ACCEPTED' AND [IsAdmin] = 1
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, boardId);
            
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error checking board admin status", e);
        }
    }

    @Override
    public void removeBoardMember(Integer userId, Integer boardId) {
        String sql = """
            DELETE FROM [Workspace].[BoardMembers] 
            WHERE [UserId] = ? AND [BoardId] = ?
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, boardId);
            
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("No board member found to remove");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error removing board member", e);
        }
    }

    @Override
    public void updateMemberRole(Integer userId, Integer boardId, Boolean isAdmin) {
        String sql = """
            UPDATE [Workspace].[BoardMembers] 
            SET [IsAdmin] = ? 
            WHERE [UserId] = ? AND [BoardId] = ? AND [Status] = 'ACCEPTED'
            """;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, isAdmin);
            ps.setInt(2, userId);
            ps.setInt(3, boardId);
            
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("No board member found to update");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error updating member role", e);
        }
    }
} 