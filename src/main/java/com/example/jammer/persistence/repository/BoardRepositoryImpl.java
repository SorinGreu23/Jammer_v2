package com.example.jammer.persistence.repository;

import com.example.jammer.domain.Boards.Board;
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.List;

public class BoardRepositoryImpl implements BoardRepository {
    private final JdbcTemplate jdbc;

    public BoardRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbc = jdbcTemplate;
    }

    @Override
    public List<Board> getAll() {
        return jdbc.query(
                "SELECT board_id, name, owner_id FROM Boards",
                (rs, rowNum) -> new Board(
                        rs.getLong("board_id"),
                        rs.getString("name"),
                        rs.getLong("owner_id")
                )
        );
    }

    @Override
    public Board save(Board board) {
        return null;
    }
}
