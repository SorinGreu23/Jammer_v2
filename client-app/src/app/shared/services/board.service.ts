import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Board } from '../models/board.model';
import { Task } from '../models/task.model';
import {
  BoardMember,
  InviteUserRequest,
  InviteUserResponse,
} from '../models/board-member.model';
import { AuthService } from './auth.service';
import { map } from 'rxjs/operators';

export interface CreateBoardRequest {
  name: string;
  userId: number;
  username: string;
}

export interface CreateBoardResponse {
  id: number;
  name: string;
  workspaceId: number;
  createdAt: Date;
}

export interface CreateTaskRequest {
  boardId: number;
  name: string;
  description?: string;
  status: string;
  userId: number;
}

export interface UpdateTaskRequest {
  name: string;
  description?: string;
  status: string;
}

export interface TaskResponse {
  id: number;
  boardId: number;
  name: string;
  description?: string;
  status: string;
  createdAt: Date;
  updatedAt?: Date;
  userId: number;
}

export interface BoardStatistics {
  boardId: number;
  boardName: string;
  totalTasks: number;
  completedTasks: number;
  completionPercentage: number;
}

export interface AcceptInvitationResponse {
  boardId: number;
  message: string;
}

@Injectable({
  providedIn: 'root',
})
export class BoardService {
  private readonly API_URL = 'http://localhost:8080/api';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    try {
      const userId = this.authService.getCurrentUserId();
      return new HttpHeaders({
        'X-User-Id': userId.toString(),
      });
    } catch (error) {
      console.error('Error getting user ID for headers:', error);
      // Navigate to login if user is not authenticated
      throw new Error('User authentication required');
    }
  }

  getBoardsByUserId(userId: number): Observable<Board[]> {
    return this.http.get<Board[]>(`${this.API_URL}/boards/user/${userId}`, {
      headers: this.getHeaders(),
      withCredentials: true,
    });
  }

  getBoardStatistics(userId: number): Observable<BoardStatistics[]> {
    return this.http.get<BoardStatistics[]>(
      `${this.API_URL}/boards/user/${userId}/statistics`,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  getTasksByBoardId(boardId: number): Observable<Task[]> {
    return this.http.get<Task[]>(`${this.API_URL}/boards/${boardId}/tasks`, {
      headers: this.getHeaders(),
      withCredentials: true,
    });
  }

  createBoard(request: CreateBoardRequest): Observable<CreateBoardResponse> {
    return this.http.post<CreateBoardResponse>(
      `${this.API_URL}/boards`,
      request,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  createTask(
    boardId: number,
    request: CreateTaskRequest
  ): Observable<TaskResponse> {
    return this.http.post<TaskResponse>(
      `${this.API_URL}/boards/${boardId}/tasks`,
      request,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  updateTask(
    taskId: number,
    request: UpdateTaskRequest
  ): Observable<TaskResponse> {
    return this.http.put<TaskResponse>(
      `${this.API_URL}/tasks/${taskId}`,
      request,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  deleteTask(taskId: number): Observable<void> {
    return this.http.delete<void>(`${this.API_URL}/tasks/${taskId}`, {
      headers: this.getHeaders(),
      withCredentials: true,
    });
  }

  // Board collaboration methods
  getBoardMembers(boardId: number): Observable<BoardMember[]> {
    return this.http.get<BoardMember[]>(
      `${this.API_URL}/boards/${boardId}/members`,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  hasBoardMembers(boardId: number): Observable<boolean> {
    return this.getBoardMembers(boardId).pipe(
      map(
        (members) => members.filter((m) => m.status === 'ACCEPTED').length > 0
      )
    );
  }

  inviteUserToBoard(
    boardId: number,
    request: InviteUserRequest
  ): Observable<InviteUserResponse> {
    const payload = {
      usernameOrEmail: request.usernameOrEmail,
    };

    return this.http.post<InviteUserResponse>(
      `${this.API_URL}/boards/${boardId}/invite`,
      payload,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  acceptBoardInvitation(token: string): Observable<AcceptInvitationResponse> {
    return this.http.post<AcceptInvitationResponse>(
      `${this.API_URL}/boards/join`,
      { token },
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  deleteBoard(boardId: number): Observable<void> {
    return this.http.delete<void>(`${this.API_URL}/boards/${boardId}`, {
      headers: this.getHeaders(),
      withCredentials: true,
    });
  }

  removeBoardMember(boardId: number, userId: number): Observable<void> {
    return this.http.delete<void>(
      `${this.API_URL}/boards/${boardId}/members/${userId}`,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }

  leaveBoard(boardId: number): Observable<void> {
    return this.http.delete<void>(`${this.API_URL}/boards/${boardId}/leave`, {
      headers: this.getHeaders(),
      withCredentials: true,
    });
  }
}
