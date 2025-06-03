import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { Router } from '@angular/router';
import { AuthService } from '../../shared/services/auth.service';
import { BoardService, CreateBoardRequest } from '../../shared/services/board.service';
import { Board } from '../../shared/models/board.model';
import { Task } from '../../shared/models/task.model';
import { forkJoin } from 'rxjs';

export interface BoardWithTasks extends Board {
  taskCount: number;
  pendingTasks: number;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, ButtonModule, DialogModule, InputTextModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
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
    if (this.currentUser && this.currentUser.userId) {
      this.loadBoards();
    }
  }

  loadBoards(): void {
    this.loading = true;
    
    this.boardService.getBoardsByUserId(this.currentUser.userId).subscribe({
      next: (boards: Board[]) => {
        if (boards.length > 0) {
          // Get task counts for each board
          const taskRequests = boards.map(board => 
            this.boardService.getTasksByBoardId(board.id)
          );
          
          forkJoin(taskRequests).subscribe({
            next: (taskArrays: Task[][]) => {
              this.boards = boards.map((board, index) => {
                const tasks = taskArrays[index];
                const pendingTasks = tasks.filter(task => 
                  task.status && !['completed', 'done'].includes(task.status.toLowerCase())
                ).length;
                
                return {
                  ...board,
                  taskCount: tasks.length,
                  pendingTasks: pendingTasks
                };
              });
              this.loading = false;
            },
            error: (error) => {
              console.error('Error loading tasks:', error);
              // Still show boards even if tasks fail to load
              this.boards = boards.map(board => ({
                ...board,
                taskCount: 0,
                pendingTasks: 0
              }));
              this.loading = false;
            }
          });
        } else {
          this.boards = [];
          this.loading = false;
        }
      },
      error: (error) => {
        console.error('Error loading boards:', error);
        this.loading = false;
      }
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
      userId: this.currentUser.userId
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
      }
    });
  }

  onLogout(): void {
    this.authService.logout();
  }
}
