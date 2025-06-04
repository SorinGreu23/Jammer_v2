import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextarea } from 'primeng/inputtextarea';
import { AvatarModule } from 'primeng/avatar';
import { CardModule } from 'primeng/card';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../shared/services/auth.service';
import {
  UserService,
  UserStatistics,
  UpdateUserProfileRequest,
} from '../../shared/services/user.service';

@Component({
  selector: 'app-account',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ButtonModule,
    InputTextModule,
    InputTextarea,
    AvatarModule,
    CardModule,
    FormsModule,
  ],
  templateUrl: './account.component.html',
  styleUrls: ['./account.component.scss'],
})
export class AccountComponent implements OnInit {
  currentUser: any;
  userStats: UserStatistics | null = null;
  loading = true;
  editingProfile = false;
  profileForm = {
    firstName: '',
    lastName: '',
  };

  constructor(
    private router: Router,
    private authService: AuthService,
    private userService: UserService
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    if (this.currentUser?.userId) {
      this.loadUserStatistics();
    }
  }

  loadUserStatistics(): void {
    this.loading = true;
    this.userService.getUserStatistics(this.currentUser.userId).subscribe({
      next: (stats) => {
        this.userStats = stats;
        this.profileForm.firstName = stats.firstName || '';
        this.profileForm.lastName = stats.lastName || '';
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading user statistics:', error);
        this.loading = false;
      },
    });
  }

  startEditing(): void {
    this.editingProfile = true;
  }

  cancelEditing(): void {
    this.editingProfile = false;
    this.profileForm.firstName = this.userStats?.firstName || '';
    this.profileForm.lastName = this.userStats?.lastName || '';
  }

  saveProfile(): void {
    if (!this.currentUser?.userId) return;

    const request: UpdateUserProfileRequest = {
      firstName: this.profileForm.firstName,
      lastName: this.profileForm.lastName,
    };

    this.userService
      .updateUserProfile(this.currentUser.userId, request)
      .subscribe({
        next: (response) => {
          this.userStats = response;
          this.editingProfile = false;
        },
        error: (error) => {
          console.error('Error updating profile:', error);
        },
      });
  }

  goBackToDashboard(): void {
    this.router.navigate(['/dashboard']);
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/']);
  }

  getInitials(): string {
    if (this.userStats?.firstName && this.userStats?.lastName) {
      return (
        this.userStats.firstName.charAt(0) + this.userStats.lastName.charAt(0)
      ).toUpperCase();
    }
    return this.userStats?.username?.charAt(0).toUpperCase() || 'U';
  }
}
