import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials {
  email: string;
  username: string;
  password: string;
  confirmPassword: string;
}

export interface AuthResponse {
  userId: number;
  username: string;
  email: string;
}

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly API_URL = 'http://localhost:8080/api'; // Adjust based on your backend URL
  private currentUserSubject = new BehaviorSubject<any>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient, private router: Router) {
    // Check if user is already logged in
    const storedUser = localStorage.getItem('currentUser');
    if (storedUser) {
      this.currentUserSubject.next(JSON.parse(storedUser));
    }
  }
  
  login(credentials: LoginCredentials): Observable<AuthResponse> {
    console.log(
      'AuthService: Attempting login with URL:',
      `${this.API_URL}/users/login`
    );
    console.log('AuthService: Credentials:', credentials);

    return this.http
      .post<AuthResponse>(`${this.API_URL}/users/login`, credentials, {
        withCredentials: true,
      })
      .pipe(
        tap((response) => {
          console.log('AuthService: Login response received:', response);
          // Store user data (backend returns user data directly, not nested)
          localStorage.setItem('currentUser', JSON.stringify(response));
          this.currentUserSubject.next(response);
        })
      );
  }

  register(credentials: RegisterCredentials): Observable<AuthResponse> {
    console.log('AuthService: Attempting register with URL:',
      `${this.API_URL}/users/register`
    );
    console.log('AuthService: Credentials:', credentials);

    return this.http
      .post<AuthResponse>(`${this.API_URL}/users/register`, credentials, {
        withCredentials: true,
      })
      .pipe(
        tap((response) => {
          console.log('AuthService: Register response received:', response);
          localStorage.setItem('currentUser', JSON.stringify(response));
          this.currentUserSubject.next(response);
        })
      );
  }

  logout(): void {
    localStorage.removeItem('currentUser');
    this.currentUserSubject.next(null);
    this.router.navigate(['/login']);
  }
  
  isLoggedIn(): boolean {
    return !!localStorage.getItem('currentUser');
  }

  getCurrentUser(): any {
    return this.currentUserSubject.value;
  }
}
