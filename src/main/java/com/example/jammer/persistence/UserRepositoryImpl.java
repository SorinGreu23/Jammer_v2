package com.example.jammer.persistence;

import com.example.jammer.domain.model.User;
import com.example.jammer.domain.repository.UserRepository;
import com.example.jammer.infrastructure.ConnectionFactory;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.util.Optional;

@Repository
public class UserRepositoryImpl implements UserRepository {

    private final ConnectionFactory connectionFactory;

    public UserRepositoryImpl(ConnectionFactory connectionFactory) {
        this.connectionFactory = connectionFactory;
    }

    @Override
    public boolean existsByUsername(String username) {
        String sql = """
            SELECT 1
              FROM [Workspace].[Users]
             WHERE [Username] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error checking username existence", e);
        }
    }

    @Override
    public boolean existsByEmail(String email) {
        String sql = """
            SELECT 1
              FROM [Workspace].[Users]
             WHERE [Email] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error checking email existence", e);
        }
    }

    @Override
    public Optional<User> findById(int id) {
        String sql = """
            SELECT [Id], [Username], [Email], [PasswordHash], [FirstName], [LastName], [CreatedAt]
              FROM [Workspace].[Users]
             WHERE [Id] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
                return Optional.empty();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading user by id", e);
        }
    }

    @Override
    public Optional<User> findByEmail(String email) {
        String sql = """
            SELECT [Id], [Username], [Email], [PasswordHash], [FirstName], [LastName], [CreatedAt]
              FROM [Workspace].[Users]
             WHERE [Email] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
                return Optional.empty();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading user by email", e);
        }
    }

    @Override
    public User save(User user) {
        if (user.getId() <= 0) {
            return insert(user);
        } else {
            return update(user);
        }
    }

    @Override
    public User findByUsername(String username) {
        String sql = """
            SELECT [Id], [Username], [Email], [PasswordHash], [FirstName], [LastName], [CreatedAt]
              FROM [Workspace].[Users]
             WHERE [Username] = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
                return null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error loading user by username", e);
        }
    }

    private User insert(User user) {
        String sql = """
            INSERT INTO [Workspace].[Users]
                ([Username], [Email], [PasswordHash], [FirstName], [LastName], [CreatedAt])
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFirstName());
            ps.setString(5, user.getLastName());
            ps.setDate(6, (user.getCreatedAt() != null
                    ? (Date) user.getCreatedAt()
                    : Date.valueOf(LocalDate.now())));

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Creating user failed, no rows affected.");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int newId = keys.getInt(1);
                    user.setId(newId);
                    return user;
                } else {
                    throw new RuntimeException("Creating user failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error inserting user", e);
        }
    }

    private User update(User user) {
        String sql = """
            UPDATE [Workspace].[Users]
               SET [Username]     = ?,
                   [Email]        = ?,
                   [PasswordHash] = ?,
                   [FirstName]    = ?,
                   [LastName]     = ?
             WHERE [Id]           = ?
            """;
        try (Connection conn = connectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFirstName());
            ps.setString(5, user.getLastName());
            ps.setInt(6, user.getId());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new RuntimeException("Updating user failed, no rows affected.");
            }
            return user;
        } catch (SQLException e) {
            throw new RuntimeException("Error updating user", e);
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        return new User(
                rs.getInt("Id"),
                rs.getString("Username"),
                rs.getString("Email"),
                rs.getString("PasswordHash"),
                rs.getString("FirstName"),
                rs.getString("LastName"),
                rs.getDate("CreatedAt")
        );
    }
}
