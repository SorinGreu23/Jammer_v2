import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextarea } from 'primeng/inputtextarea';
import { ToastModule } from 'primeng/toast';
import { MessageService } from 'primeng/api';
import {
  DragDropModule,
  CdkDragDrop,
  moveItemInArray,
  transferArrayItem,
} from '@angular/cdk/drag-drop';
import {
  BoardService,
  CreateTaskRequest,
  UpdateTaskRequest,
} from '../../shared/services/board.service';
import { AuthService } from '../../shared/services/auth.service';
import { Board } from '../../shared/models/board.model';
import { Task } from '../../shared/models/task.model';
import {
  BoardMember,
  InviteUserRequest,
} from '../../shared/models/board-member.model';

@Component({
  selector: 'app-board',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ButtonModule,
    CardModule,
    DialogModule,
    InputTextModule,
    InputTextarea,
    ToastModule,
    DragDropModule,
  ],
  providers: [MessageService],
  templateUrl: './board.component.html',
  styleUrl: './board.component.scss',
})
export class BoardComponent implements OnInit {
  boardId!: number;
  board: Board | null = null;
  tasks: Task[] = [];
  loading = true;
  currentUser: any;

  // Task status categories - 5 column Kanban aligned with DB constraints
  todoTasks: Task[] = []; // TODO status
  inProgressTasks: Task[] = []; // IN_PROGRESS status
  testingTasks: Task[] = []; // TESTING status
  reviewTasks: Task[] = []; // REVIEW status
  doneTasks: Task[] = []; // DONE status

  // Create/Edit task modal properties
  showCreateTaskModal = false;
  newTaskName = '';
  newTaskDescription = '';
  creatingTask = false;
  isEditMode = false;
  editingTask: Task | null = null;

  // Drag and drop tracking
  updatingTaskStatus = false;

  // Task deletion tracking
  deletingTaskId: number | null = null;

  // Board collaboration properties
  boardMembers: BoardMember[] = [];
  showInviteModalVisible = false;
  showMembersModalVisible = false;
  inviteUsernameOrEmail = '';
  invitingUser = false;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private boardService: BoardService,
    private authService: AuthService,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();

    // Get board ID from route
    this.route.params.subscribe((params) => {
      this.boardId = +params['id'];
      if (this.boardId) {
        this.loadBoardData();
      }
    });
  }

  loadBoardData(): void {
    this.loading = true;

    // Since there's no direct GET /boards/{id} endpoint,
    // we'll get all user boards and find the one we need
    if (this.currentUser && this.currentUser.userId) {
      this.boardService.getBoardsByUserId(this.currentUser.userId).subscribe({
        next: (boards: Board[]) => {
          this.board = boards.find((b) => b.id === this.boardId) || null;

          if (this.board) {
            this.loadTasks();
            this.loadBoardMembers();
          } else {
            console.error('Board not found or access denied');
            this.router.navigate(['/dashboard']);
          }
        },
        error: (error) => {
          console.error('Error loading board:', error);
          this.loading = false;
          this.router.navigate(['/dashboard']);
        },
      });
    }
  }

  loadTasks(): void {
    this.boardService.getTasksByBoardId(this.boardId).subscribe({
      next: (tasks: Task[]) => {
        this.tasks = tasks;
        this.categorizeTasks();
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading tasks:', error);
        this.loading = false;
      },
    });
  }

  loadBoardMembers(): void {
    this.boardService.getBoardMembers(this.boardId).subscribe({
      next: (members: BoardMember[]) => {
        this.boardMembers = members;
      },
      error: (error) => {
        console.error('Error loading board members:', error);
        this.messageService.add({
          severity: 'error',
          summary: 'Error',
          detail: 'Failed to load board members',
        });
      },
    });
  }

  categorizeTasks(): void {
    this.todoTasks = this.tasks.filter(
      (task) => !task.status || task.status.toUpperCase() === 'TODO'
    );

    this.inProgressTasks = this.tasks.filter(
      (task) => task.status && task.status.toUpperCase() === 'IN_PROGRESS'
    );

    this.testingTasks = this.tasks.filter(
      (task) => task.status && task.status.toUpperCase() === 'TESTING'
    );

    this.reviewTasks = this.tasks.filter(
      (task) => task.status && task.status.toUpperCase() === 'REVIEW'
    );

    this.doneTasks = this.tasks.filter(
      (task) => task.status && task.status.toUpperCase() === 'DONE'
    );
  }

  goBackToDashboard(): void {
    this.router.navigate(['/dashboard']);
  }

  getTaskStatusColor(status: string): string {
    if (!status) return 'todo';

    switch (status.toUpperCase()) {
      case 'TODO':
        return 'todo';
      case 'IN_PROGRESS':
        return 'in-progress';
      case 'TESTING':
        return 'testing';
      case 'REVIEW':
        return 'review';
      case 'DONE':
        return 'done';
      default:
        return 'todo';
    }
  }

  // Task creation/editing methods
  openCreateTaskModal(): void {
    this.isEditMode = false;
    this.editingTask = null;
    this.showCreateTaskModal = true;
    this.newTaskName = '';
    this.newTaskDescription = '';
  }

  openEditTaskModal(task: Task, event: Event): void {
    // Prevent drag from starting when clicking edit button
    event.stopPropagation();

    this.isEditMode = true;
    this.editingTask = task;
    this.showCreateTaskModal = true;
    this.newTaskName = task.name;
    this.newTaskDescription = task.description || '';
  }

  closeCreateTaskModal(): void {
    this.showCreateTaskModal = false;
    this.newTaskName = '';
    this.newTaskDescription = '';
    this.creatingTask = false;
    this.isEditMode = false;
    this.editingTask = null;
  }

  createTask(): void {
    if (!this.newTaskName.trim()) {
      return;
    }

    this.creatingTask = true;
    const taskName = this.newTaskName.trim(); // Capture task name before modal closes

    const request: CreateTaskRequest = {
      boardId: this.boardId,
      name: taskName,
      description: this.newTaskDescription.trim() || undefined,
      status: 'TODO',
      userId: this.currentUser.userId,
    };

    this.boardService.createTask(this.boardId, request).subscribe({
      next: (response: any) => {
        console.log('✅ Task created successfully:', response);
        this.closeCreateTaskModal();
        // Refresh the tasks list
        this.loadTasks();
        
        this.messageService.add({
          severity: 'success',
          summary: 'Task Created',
          detail: `Task "${taskName}" has been created`,
        });
      },
      error: (error: any) => {
        console.error('❌ Error creating task:', error);
        
        // Extract meaningful error message from server response
        let errorMessage = 'Failed to create task. Please try again.';
        let summary = 'Create Failed';
        
        if (error?.error?.message) {
          errorMessage = error.error.message;
          
          if (error.status === 400) {
            summary = 'Invalid Task Data';
          }
        }
        
        this.messageService.add({
          severity: 'error',
          summary: summary,
          detail: errorMessage,
        });
        
        this.creatingTask = false;
      },
    });
  }

  updateTask(): void {
    if (!this.newTaskName.trim() || !this.editingTask) {
      return;
    }

    this.creatingTask = true;
    const taskName = this.newTaskName.trim(); // Capture task name before modal closes

    const request: UpdateTaskRequest = {
      name: taskName,
      description: this.newTaskDescription.trim() || undefined,
      status: this.editingTask.status,
    };

    this.boardService.updateTask(this.editingTask.id, request).subscribe({
      next: (response: any) => {
        console.log('✅ Task updated successfully:', response);

        // Update the task in local arrays
        this.editingTask!.name = taskName;
        this.editingTask!.description =
          this.newTaskDescription.trim() || undefined;

        this.closeCreateTaskModal();
        
        this.messageService.add({
          severity: 'success',
          summary: 'Task Updated',
          detail: `Task "${taskName}" has been updated`,
        });
      },
      error: (error: any) => {
        console.error('❌ Error updating task:', error);
        
        // Extract meaningful error message from server response
        let errorMessage = 'Failed to update task. Please try again.';
        let summary = 'Update Failed';
        
        if (error?.error?.message) {
          errorMessage = error.error.message;
          
          if (error.status === 404) {
            summary = 'Task Not Found';
            errorMessage = 'The task could not be found. It may have been deleted.';
          } else if (error.status === 400) {
            summary = 'Invalid Task Data';
          }
        }
        
        this.messageService.add({
          severity: 'error',
          summary: summary,
          detail: errorMessage,
        });
        
        this.creatingTask = false;
      },
    });
  }

  deleteTask(task: Task, event: Event): void {
    // Prevent drag from starting when clicking delete button
    event.stopPropagation();

    // Only allow deletion of non-done tasks (client-side check)
    if (task.status && task.status.toUpperCase() === 'DONE') {
      this.messageService.add({
        severity: 'warn',
        summary: 'Cannot Delete',
        detail: 'Completed tasks cannot be deleted',
      });
      return;
    }

    if (this.deletingTaskId === task.id) {
      return; // Already deleting this task
    }

    this.deletingTaskId = task.id;

    this.boardService.deleteTask(task.id).subscribe({
      next: () => {
        console.log('✅ Task deleted successfully:', task.name);
        
        // Remove task from local arrays
        this.tasks = this.tasks.filter(t => t.id !== task.id);
        this.categorizeTasks();
        
        this.messageService.add({
          severity: 'success',
          summary: 'Task Deleted',
          detail: `Task "${task.name}" has been deleted`,
        });
        
        this.deletingTaskId = null;
      },
      error: (error: any) => {
        console.error('❌ Error deleting task:', error);
        
        // Extract meaningful error message from server response
        let errorMessage = 'Failed to delete task. Please try again.';
        let severity = 'error';
        let summary = 'Delete Failed';
        
        if (error?.error?.message) {
          errorMessage = error.error.message;
          
          // Customize message based on error type
          if (error.status === 404) {
            summary = 'Task Not Found';
            errorMessage = 'The task could not be found. It may have already been deleted.';
          } else if (error.status === 403) {
            summary = 'Delete Not Allowed';
            severity = 'warn';
          } else if (error.status === 400) {
            summary = 'Invalid Request';
            severity = 'warn';
          }
        }
        
        this.messageService.add({
          severity: severity as any,
          summary: summary,
          detail: errorMessage,
        });
        
        this.deletingTaskId = null;
      },
    });
  }

  isTaskDeletable(task: Task): boolean {
    return !task.status || task.status.toUpperCase() !== 'DONE';
  }

  // Drag and drop methods
  onTaskDrop(event: CdkDragDrop<Task[]>, newStatus: string): void {
    const task = event.item.data as Task;

    if (event.previousContainer === event.container) {
      // Same column, just reorder
      moveItemInArray(
        event.container.data,
        event.previousIndex,
        event.currentIndex
      );
      console.log('📋 Task reordered within column');
    } else {
      // Different column, move task and update status
      console.log(`🔄 Moving "${task.name}" to ${newStatus}`);
      this.moveTaskToNewStatus(task, event, newStatus);
    }
  }

  onDragStarted(event: any): void {
    // Removed noisy debug log
  }

  onDragEnded(event: any): void {
    // Removed noisy debug log
  }

  private moveTaskToNewStatus(
    task: Task,
    event: CdkDragDrop<Task[]>,
    newStatus: string
  ): void {
    if (this.updatingTaskStatus) {
      return; // Prevent multiple simultaneous updates
    }

    this.updatingTaskStatus = true;

    // Optimistically update the UI first
    const oldStatus = task.status;
    task.status = newStatus;

    // Move task between arrays immediately
    transferArrayItem(
      event.previousContainer.data,
      event.container.data,
      event.previousIndex,
      event.currentIndex
    );

    // Try to update backend with full task data
    const request: UpdateTaskRequest = {
      name: task.name,
      description: task.description || undefined,
      status: newStatus,
    };

    this.boardService.updateTask(task.id, request).subscribe({
      next: (response: any) => {
        console.log(
          '✅ Task status updated successfully in backend:',
          response
        );
        this.updatingTaskStatus = false;
      },
      error: (error: any) => {
        console.error(
          '❌ Backend update failed, but UI change remains:',
          error
        );
        console.log('💡 Task moved locally from', oldStatus, 'to', newStatus);

        // Don't revert the change - let the user see the movement
        // They can refresh if they want to sync with backend
        this.updatingTaskStatus = false;
      },
    });
  }

  // Get the correct status string for each column
  getColumnStatus(columnType: string): string {
    switch (columnType) {
      case 'todo':
        return 'TODO';
      case 'in-progress':
        return 'IN_PROGRESS';
      case 'testing':
        return 'TESTING';
      case 'review':
        return 'REVIEW';
      case 'done':
        return 'DONE';
      default:
        return 'TODO';
    }
  }

  // Board collaboration methods
  showInviteModal(): void {
    this.showInviteModalVisible = true;
    this.inviteUsernameOrEmail = '';
  }

  closeInviteModal(): void {
    this.showInviteModalVisible = false;
    this.inviteUsernameOrEmail = '';
    this.invitingUser = false;
  }

  showMembersModal(): void {
    this.showMembersModalVisible = true;
    this.loadBoardMembers(); // Refresh members list
  }

  closeMembersModal(): void {
    this.showMembersModalVisible = false;
  }

  inviteUser(): void {
    if (!this.inviteUsernameOrEmail.trim()) {
      return;
    }

    this.invitingUser = true;

    const request: InviteUserRequest = {
      usernameOrEmail: this.inviteUsernameOrEmail.trim(),
      boardId: this.boardId,
    };

    this.boardService.inviteUserToBoard(this.boardId, request).subscribe({
      next: (response) => {
        console.log('✅ User invited successfully:', response);
        this.messageService.add({
          severity: 'success',
          summary: 'Invitation Sent',
          detail: response.message || 'Invitation sent successfully',
        });

        this.closeInviteModal();
        this.loadBoardMembers(); // Refresh members list
      },
      error: (error) => {
        console.error('❌ Error inviting user:', error);
        this.messageService.add({
          severity: 'error',
          summary: 'Invitation Failed',
          detail:
            error.error?.message ||
            'Failed to send invitation. Please try again.',
        });
      },
      complete: () => {
        this.invitingUser = false;
      },
    });
  }
}
