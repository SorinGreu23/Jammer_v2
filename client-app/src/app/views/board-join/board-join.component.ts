import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import {
  BoardService,
  AcceptInvitationResponse,
} from '../../shared/services/board.service';
import { HttpErrorResponse } from '@angular/common/http';

@Component({
  selector: 'app-board-join',
  standalone: true,
  imports: [CommonModule, ProgressSpinnerModule, ToastModule],
  providers: [MessageService],
  template: `
    <div class="join-container">
      <div class="bg-elements">
        <div class="bg-circle bg-circle-1"></div>
        <div class="bg-circle bg-circle-2"></div>
        <div class="bg-circle bg-circle-3"></div>
      </div>

      <div class="join-content">
        <div class="spinner-container" *ngIf="loading">
          <p-progressSpinner></p-progressSpinner>
          <p>Processing your invitation...</p>
        </div>
      </div>
    </div>
    <p-toast></p-toast>
  `,
  styles: [
    `
      .join-container {
        height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: var(--surface-ground);
        position: relative;
        overflow: hidden;
      }

      .bg-elements {
        position: absolute;
        width: 100%;
        height: 100%;
        overflow: hidden;
        z-index: 0;
      }

      .bg-circle {
        position: absolute;
        border-radius: 50%;
        opacity: 0.1;
      }

      .bg-circle-1 {
        width: 600px;
        height: 600px;
        background: linear-gradient(
          180deg,
          var(--primary-color) 0%,
          var(--primary-700) 100%
        );
        top: -100px;
        right: -100px;
      }

      .bg-circle-2 {
        width: 400px;
        height: 400px;
        background: linear-gradient(
          180deg,
          var(--primary-color) 0%,
          var(--primary-700) 100%
        );
        bottom: -50px;
        left: -50px;
      }

      .bg-circle-3 {
        width: 300px;
        height: 300px;
        background: linear-gradient(
          180deg,
          var(--primary-color) 0%,
          var(--primary-700) 100%
        );
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
      }

      .join-content {
        position: relative;
        z-index: 1;
        background: var(--surface-card);
        padding: 2rem;
        border-radius: 12px;
        box-shadow: var(--card-shadow);
        text-align: center;
      }

      .spinner-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1rem;

        p {
          color: var(--text-color);
          margin: 0;
        }
      }
    `,
  ],
})
export class BoardJoinComponent implements OnInit {
  loading = true;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private boardService: BoardService,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    // Get the token from the URL query parameters
    this.route.queryParams.subscribe((params) => {
      const token = params['token'];
      if (token) {
        this.joinBoard(token);
      } else {
        this.handleError('Invalid invitation link');
      }
    });
  }

  private joinBoard(token: string): void {
    this.boardService.acceptBoardInvitation(token).subscribe({
      next: (response: AcceptInvitationResponse) => {
        this.messageService.add({
          severity: 'success',
          summary: 'Welcome!',
          detail: 'You have successfully joined the board.',
        });

        // Redirect to the board after a short delay
        setTimeout(() => {
          this.router.navigate(['/board', response.boardId]);
        }, 1500);
      },
      error: (error: HttpErrorResponse) => {
        console.error('Error joining board:', error);
        this.handleError(
          error.error?.message || 'Failed to join the board. Please try again.'
        );
      },
    });
  }

  private handleError(message: string): void {
    this.loading = false;
    this.messageService.add({
      severity: 'error',
      summary: 'Error',
      detail: message,
    });

    // Redirect to dashboard after error
    setTimeout(() => {
      this.router.navigate(['/dashboard']);
    }, 3000);
  }
}
