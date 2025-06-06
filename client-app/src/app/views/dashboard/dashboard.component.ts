import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ConfirmationService, MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { Router } from '@angular/router';
import { AuthService } from '../../shared/services/auth.service';
import {
  BoardService,
  CreateBoardRequest,
  BoardStatistics,
} from '../../shared/services/board.service';
import { WorkspaceService } from '../../shared/services/workspace.service';
import { Board } from '../../shared/models/board.model';
import { Workspace } from '../../shared/models/workspace.model';
import { Task } from '../../shared/models/task.model';
import { forkJoin } from 'rxjs';
import { map } from 'rxjs/operators';

export interface BoardWithDetails extends Board {
  taskCount: number;
  pendingTasks: number;
  completedTasks: number;
  completionPercentage: number;
  workspaceName: string;
  isOwnWorkspace: boolean;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    ButtonModule,
    DialogModule,
    InputTextModule,
    ConfirmDialogModule,
    ToastModule,
  ],
  providers: [ConfirmationService, MessageService],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  title = 'Dashboard - Jammer';
  currentUser: any;
  currentDate = new Date();

  boards: BoardWithDetails[] = [];
  workspaces: { [key: number]: Workspace } = {};
  loading = true;

  // Modal properties
  showCreateModal = false;
  newBoardName = '';
  creatingBoard = false;

  constructor(
    private authService: AuthService,
    private boardService: BoardService,
    private workspaceService: WorkspaceService,
    private router: Router,
    private confirmationService: ConfirmationService,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    if (this.currentUser) {
      this.loadBoardsAndWorkspaces();
    }
  }

  loadBoardsAndWorkspaces(): void {
    this.loading = true;

    if (!this.currentUser?.userId) {
      this.loading = false;
      return;
    }

    // Get boards, statistics, and workspace
    forkJoin({
      boards: this.boardService.getBoardsByUserId(this.currentUser.userId),
      stats: this.boardService.getBoardStatistics(this.currentUser.userId),
      workspace: this.workspaceService.getWorkspaceByUserId(
        this.currentUser.userId
      ),
    }).subscribe({
      next: ({ boards, stats, workspace }) => {
        // Store workspace
        this.workspaces[workspace.id] = workspace;

        // Merge board info with statistics and workspace
        this.boards = boards.map((board) => {
          const boardStats = stats.find((s) => s.boardId === board.id) || {
            totalTasks: 0,
            completedTasks: 0,
            completionPercentage: 0,
          };

          const isOwnWorkspace = board.workspaceId === workspace.id;
          const workspaceName = isOwnWorkspace
            ? 'My Workspace'
            : 'Shared Board';

          return {
            ...board,
            taskCount: boardStats.totalTasks,
            pendingTasks: boardStats.totalTasks - boardStats.completedTasks,
            completedTasks: boardStats.completedTasks,
            completionPercentage: boardStats.completionPercentage,
            workspaceName,
            isOwnWorkspace,
          };
        });

        // Sort boards: own workspace first, then shared boards
        this.boards.sort((a, b) => {
          if (a.isOwnWorkspace && !b.isOwnWorkspace) return -1;
          if (!a.isOwnWorkspace && b.isOwnWorkspace) return 1;
          return 0;
        });

        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading boards and workspaces:', error);
        this.loading = false;
      },
    });
  }

  onBoardClick(board: BoardWithDetails): void {
    this.router.navigate(['/board', board.id]);
  }

  // Modal methods
  openCreateModal(): void {
    this.showCreateModal = true;
    this.newBoardName = '';
  }

  closeCreateModal(): void {
    this.showCreateModal = false;
    this.newBoardName = '';
    this.creatingBoard = false;
  }

  createBoard(): void {
    if (!this.currentUser) return;

    this.creatingBoard = true;
    this.boardService
      .createBoard({
        name: this.newBoardName,
        userId: this.currentUser.userId,
        username: this.currentUser.username,
      })
      .subscribe({
        next: () => {
          this.messageService.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Board created successfully',
          });
          this.closeCreateModal();
          this.loadBoardsAndWorkspaces();
        },
        error: (error) => {
          console.error('Error creating board:', error);
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: 'Failed to create board. Please try again.',
          });
        },
        complete: () => {
          this.creatingBoard = false;
        },
      });
  }

  onLogout(): void {
    this.authService.logout();
  }

  deleteBoard(board: BoardWithDetails, event: Event): void {
    event.stopPropagation(); // Prevent board click event

    this.confirmationService.confirm({
      message: `Are you sure you want to delete the board "${board.name}"? This action cannot be undone and will remove access for all members.`,
      header: 'Delete Board',
      icon: 'pi pi-exclamation-triangle',
      accept: () => {
        this.boardService.deleteBoard(board.id).subscribe({
          next: () => {
            this.messageService.add({
              severity: 'success',
              summary: 'Success',
              detail: 'Board deleted successfully',
            });
            this.loadBoardsAndWorkspaces();
          },
          error: (error) => {
            console.error('Error deleting board:', error);
            
            let errorMessage = 'Failed to delete board. Please try again.';
            
            // Handle specific error types
            if (error.status === 404) {
              errorMessage = 'Board not found. It may have already been deleted.';
            } else if (error.status === 403) {
              errorMessage = 'You do not have permission to delete this board. Only workspace owners can delete boards.';
            } else if (error.status === 401) {
              errorMessage = 'Your session has expired. Please log in again.';
              // Redirect to login
              this.authService.logout();
              return;
            } else if (error.error && error.error.message) {
              errorMessage = error.error.message;
            }
            
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: errorMessage,
            });
          },
        });
      },
    });
  }

  isOwner(board: BoardWithDetails): boolean {
    return board.isOwnWorkspace;
  }
}
