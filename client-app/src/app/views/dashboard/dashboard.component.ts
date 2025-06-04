import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { Router } from '@angular/router';
import { AuthService } from '../../shared/services/auth.service';
import {
  BoardService,
  CreateBoardRequest,
  BoardStatistics,
} from '../../shared/services/board.service';
import { Board } from '../../shared/models/board.model';
import { Task } from '../../shared/models/task.model';
import { forkJoin } from 'rxjs';

export interface BoardWithTasks extends Board {
  taskCount: number;
  pendingTasks: number;
  completedTasks: number;
  completionPercentage: number;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, ButtonModule, DialogModule, InputTextModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  title = 'Dashboard - Jammer';
  currentUser: any;
  currentDate = new Date();

  boards: BoardWithTasks[] = [];
  loading = true;

  // Modal properties
  showCreateModal = false;
  newBoardName = '';
  creatingBoard = false;

  constructor(
    private authService: AuthService,
    private boardService: BoardService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    if (this.currentUser) {
      this.loadBoards();
    }
  }

  loadBoards(): void {
    this.loading = true;

    if (!this.currentUser?.userId) {
      this.loading = false;
      return;
    }

    // Get both boards and their statistics
    forkJoin({
      boards: this.boardService.getBoardsByUserId(this.currentUser.userId),
      stats: this.boardService.getBoardStatistics(this.currentUser.userId),
    }).subscribe({
      next: ({ boards, stats }) => {
        // Merge board info with statistics
        this.boards = boards.map((board) => {
          const boardStats = stats.find((s) => s.boardId === board.id) || {
            totalTasks: 0,
            completedTasks: 0,
            completionPercentage: 0,
          };

          return {
            ...board,
            taskCount: boardStats.totalTasks,
            pendingTasks: boardStats.totalTasks - boardStats.completedTasks,
            completedTasks: boardStats.completedTasks,
            completionPercentage: boardStats.completionPercentage,
          };
        });
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading boards:', error);
        this.loading = false;
      },
    });
  }

  onBoardClick(board: BoardWithTasks): void {
    // Navigate to board detail view
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
    if (!this.newBoardName.trim()) {
      return;
    }

    this.creatingBoard = true;

    const request: CreateBoardRequest = {
      name: this.newBoardName.trim(),
      userId: this.currentUser.userId,
    };

    this.boardService.createBoard(request).subscribe({
      next: (response) => {
        console.log('Board created successfully:', response);
        this.closeCreateModal();
        // Refresh the boards list
        this.loadBoards();
      },
      error: (error) => {
        console.error('Error creating board:', error);
        this.creatingBoard = false;
        // You could add a toast notification here for better UX
      },
    });
  }

  onLogout(): void {
    this.authService.logout();
  }
}
