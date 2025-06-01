import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { NavbarComponent } from './shared/components/navbar/navbar.component'; // Import NavbarComponent

@Component({
  selector: 'app-root',
  standalone: true, // Add standalone: true
  imports: [RouterOutlet, NavbarComponent], // Add NavbarComponent to imports
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'Jammer';
}
