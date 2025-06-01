import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { MessageService } from 'primeng/api';

// PrimeNG imports
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';

import { AuthService, LoginCredentials } from '../../shared/components/auth.service';

@Component({
  selector: 'app-login',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    InputTextModule,
    PasswordModule,
    ButtonModule,
    ToastModule
  ],
  providers: [MessageService],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  isLoading = false;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    this.initializeForm();
    
    // Redirect if already logged in
    if (this.authService.isLoggedIn()) {
      this.router.navigate(['/dashboard']);
    }
  }

  private initializeForm(): void {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]]
    });
  }
  onLogin(): void {
    if (this.loginForm.valid) {
      this.isLoading = true;
      const credentials: LoginCredentials = this.loginForm.value;
      
      console.log('Attempting login with credentials:', credentials);

      this.authService.login(credentials).subscribe({
        next: (response) => {
          console.log('Login successful:', response);
          this.isLoading = false;
          this.messageService.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Login successful!'
          });
          
          // Navigate to dashboard after successful login
          setTimeout(() => {
            this.router.navigate(['/dashboard']);
          }, 1500);
        },
        error: (error) => {
          console.error('Login error:', error);
          this.isLoading = false;
          
          let errorMessage = 'Invalid email or password';
          if (error.status === 0) {
            errorMessage = 'Unable to connect to server. Please check if the backend is running.';
          } else if (error.status === 404) {
            errorMessage = 'Login endpoint not found. Please check the API URL.';
          } else if (error.status >= 500) {
            errorMessage = 'Server error. Please try again later.';
          }
          
          this.messageService.add({
            severity: 'error',
            summary: 'Login Failed',
            detail: errorMessage
          });
        }
      });
    } else {
      // Mark all fields as touched to show validation errors
      Object.keys(this.loginForm.controls).forEach(key => {
        this.loginForm.get(key)?.markAsTouched();
      });
    }
  }
}
