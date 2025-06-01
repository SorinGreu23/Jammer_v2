package com.example.jammer.application.board;

import com.example.jammer.api.dtos.board.CreateBoardRequest;
import com.example.jammer.api.dtos.board.CreateBoardResponse;
import com.example.jammer.domain.model.Board;
import com.example.jammer.domain.model.Workspace;
import com.example.jammer.domain.repository.BoardRepository;
import com.example.jammer.domain.repository.WorkspaceRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDate;

@Service
public class CreateBoardUseCase {
    private final BoardRepository boardRepository;
    private final WorkspaceRepository workspaceRepository;

    public CreateBoardUseCase(BoardRepository boardRepository, WorkspaceRepository workspaceRepository) {
        this.boardRepository = boardRepository;
        this.workspaceRepository = workspaceRepository;
    }

    @Transactional
    public CreateBoardResponse execute(CreateBoardRequest request) {
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Board name is required");
        }
        if (request.getUserId() == null) {
            throw new IllegalArgumentException("User ID is required");
        }

        Workspace workspace = workspaceRepository.findByUserId(request.getUserId());
        if (workspace == null) {
            throw new IllegalArgumentException("Workspace not found for user ID: " + request.getUserId());
        }

        Board newBoard = new Board(
                null,
                request.getName().trim(),
                workspace.getId(),
                Date.valueOf(LocalDate.now())
        );

        Board saved = boardRepository.save(newBoard);
        return new CreateBoardResponse(
                saved.getId(),
                saved.getName(),
                saved.getWorkspaceId(),
                saved.getCreatedAt()
        );
    }
}
