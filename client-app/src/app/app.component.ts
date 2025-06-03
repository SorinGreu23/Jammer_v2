import { Component, OnInit } from '@angular/core';
import { RouterOutlet, Router, NavigationEnd } from '@angular/router';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from './shared/components/navbar/navbar.component';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NavbarComponent, CommonModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'Jammer';
  showNavbar = false;

  // Routes where navbar should NOT be shown
  private routesWithoutNavbar = ['/', '/login', '/register', '/error'];

  constructor(private router: Router) {}

  ngOnInit(): void {
    // Check initial route
    this.checkRoute(this.router.url);

    // Listen to route changes
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        this.checkRoute(event.url);
      });
  }

  private checkRoute(url: string): void {
    // Remove query parameters and fragments for comparison
    const cleanUrl = url.split('?')[0].split('#')[0];
    this.showNavbar = !this.routesWithoutNavbar.includes(cleanUrl);
  }
}
