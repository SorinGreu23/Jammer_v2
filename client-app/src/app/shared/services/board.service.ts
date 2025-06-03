import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Board } from '../models/board.model';
import { Task } from '../models/task.model';

export interface CreateBoardRequest {
  name: string;
  userId: number;
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

@Injectable({
  providedIn: 'root'
})
export class BoardService {
  private readonly API_URL = 'http://localhost:8080/api';

  constructor(private http: HttpClient) {}

  getBoardsByUserId(userId: number): Observable<Board[]> {
    return this.http.get<Board[]>(`${this.API_URL}/boards/user/${userId}`, {
      withCredentials: true
    });
  }

  getTasksByBoardId(boardId: number): Observable<Task[]> {
    return this.http.get<Task[]>(`${this.API_URL}/boards/${boardId}/tasks`, {
      withCredentials: true
    });
  }

  createBoard(request: CreateBoardRequest): Observable<CreateBoardResponse> {
    return this.http.post<CreateBoardResponse>(`${this.API_URL}/boards`, request, {
      withCredentials: true
    });
  }

  createTask(boardId: number, request: CreateTaskRequest): Observable<TaskResponse> {
    return this.http.post<TaskResponse>(`${this.API_URL}/boards/${boardId}/tasks`, request, {
      withCredentials: true
    });
  }

  updateTask(taskId: number, request: UpdateTaskRequest): Observable<TaskResponse> {
    return this.http.put<TaskResponse>(`${this.API_URL}/tasks/${taskId}`, request, {
      withCredentials: true
    });
  }
} 