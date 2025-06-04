import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Workspace } from '../models/workspace.model';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root',
})
export class WorkspaceService {
  private readonly API_URL = 'http://localhost:8080/api';

  constructor(private http: HttpClient, private authService: AuthService) {}

  private getHeaders(): HttpHeaders {
    return new HttpHeaders({
      'X-User-Id': this.authService.getCurrentUserId().toString(),
    });
  }

  getWorkspaceByUserId(userId: number): Observable<Workspace> {
    return this.http.get<Workspace>(
      `${this.API_URL}/workspaces/user/${userId}`,
      {
        headers: this.getHeaders(),
        withCredentials: true,
      }
    );
  }
}
