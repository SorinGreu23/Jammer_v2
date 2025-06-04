import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface UserStatistics {
  userId: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  createdAt: string;
  boardsCount: number;
  tasksCount: number;
  projectsCount: number;
  collaborationsCount: number;
}

export interface UpdateUserProfileRequest {
  firstName: string;
  lastName: string;
}

@Injectable({
  providedIn: 'root',
})
export class UserService {
  private readonly API_URL = 'http://localhost:8080/api';

  constructor(private http: HttpClient) {}

  getUserStatistics(userId: number): Observable<UserStatistics> {
    return this.http.get<UserStatistics>(
      `${this.API_URL}/users/${userId}/statistics`,
      {
        withCredentials: true,
      }
    );
  }

  updateUserProfile(
    userId: number,
    request: UpdateUserProfileRequest
  ): Observable<UserStatistics> {
    return this.http.put<UserStatistics>(
      `${this.API_URL}/users/${userId}/profile`,
      request,
      {
        withCredentials: true,
      }
    );
  }
}
