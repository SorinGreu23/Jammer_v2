package com.example.jammer.application.board;

import com.example.jammer.domain.repository.BoardRepository;
import com.example.jammer.domain.repository.TaskRepository;
import com.example.jammer.domain.repository.WorkspaceRepository;
import com.example.jammer.domain.model.Board;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DeleteBoardUseCase {
    private final BoardRepository boardRepository;
    private final TaskRepository taskRepository;
    private final WorkspaceRepository workspaceRepository;

    public DeleteBoardUseCase(
            BoardRepository boardRepository,
            TaskRepository taskRepository,
            WorkspaceRepository workspaceRepository) {
        this.boardRepository = boardRepository;
        this.taskRepository = taskRepository;
        this.workspaceRepository = workspaceRepository;
    }

    @Transactional
    public void execute(Long boardId, Integer userId) {
        // Get the board
        Board board = boardRepository.findById(boardId);
        if (board == null) {
            throw new RuntimeException("Board not found");
        }

        // Check if user owns the workspace
        if (!workspaceRepository.isUserWorkspaceOwner(userId, board.getWorkspaceId())) {
            throw new RuntimeException("Only workspace owners can delete boards");
        }

        // First, delete all tasks associated with the board
        taskRepository.findByBoardId(boardId.intValue()).forEach(task -> {
            taskRepository.delete(task.getId());
        });

        // Delete the board - this will automatically delete all board members and invitations
        // due to ON DELETE CASCADE constraints in the database
        boardRepository.deleteById(boardId);
    }
}