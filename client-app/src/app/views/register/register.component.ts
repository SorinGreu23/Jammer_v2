import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { ToastModule } from 'primeng/toast';
import { AuthService, RegisterCredentials } from '../../shared/services/auth.service';

@Component({
  selector: 'app-register',
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
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss'
})
export class RegisterComponent {
  registerForm!: FormGroup;
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
    this.registerForm = this.fb.group({
      username: ['', [Validators.required]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]],
      confirmPassword: ['', Validators.required]
    });
  }
  onLogin(): void {
    if (this.registerForm.valid) {
      this.isLoading = true;
      const credentials: RegisterCredentials = this.registerForm.value;
      
      console.log('Attempting register with credentials:', credentials);

      this.authService.register(credentials).subscribe({
        next: (response) => {
          console.log('Register successful:', response);
          this.isLoading = false;
          this.messageService.add({
            severity: 'success',
            summary: 'Success',
            detail: 'Register successful!'
          });
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
      Object.keys(this.registerForm.controls).forEach(key => {
        this.registerForm.get(key)?.markAsTouched();
      });
    }
  }
}
