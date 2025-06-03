import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-homepage',
  standalone: true,
  imports: [CommonModule, ButtonModule, RouterModule],
  templateUrl: './homepage.component.html',
  styleUrl: './homepage.component.scss'
})
export class HomepageComponent {

  constructor(private router: Router) {}

  navigateToLogin(): void {
    console.log('Navigate to login clicked!');
    this.router.navigate(['/login']);
  }

  navigateToRegister(): void {
    console.log('Navigate to register clicked!');
    this.router.navigate(['/register']);
  }
}
