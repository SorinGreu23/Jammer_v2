import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';

export interface UserStatistics {
  userId: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  createdAt: string;
  boardsCount: number;
  tasksCount: number;
  boardsSharedWithMe: number;
  boardsSharedByMe: number;
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

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    return new HttpHeaders({
      'X-User-Id': this.authService.getCurrentUserId().toString(),
    });
  }

  getUserStatistics(userId: number): Observable<UserStatistics> {
    return this.http.get<UserStatistics>(
      `${this.API_URL}/users/${userId}/statistics`,
      {
        headers: this.getHeaders(),
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
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }
}
