import { Routes } from '@angular/router';
import { DashboardComponent } from './views/dashboard/dashboard.component';
import { LoginComponent } from './views/login/login.component';
import { RegisterComponent } from './views/register/register.component';
import { HomepageComponent } from './views/homepage/homepage.component';
import { NotFoundComponent } from './views/not-found/not-found.component';
import { InternalServerErrorComponent } from './views/internal-server-error/internal-server-error.component';
import { authGuard } from './shared/guards/auth.guard';
import { AccountComponent } from './views/account/account.component';
import { BoardComponent } from './views/board/board.component';
import { BoardJoinComponent } from './views/board-join/board-join.component';

export const routes: Routes = [
  { path: '', component: HomepageComponent },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [authGuard],
  },
  {
    path: 'board/:id',
    component: BoardComponent,
    canActivate: [authGuard],
  },
  {
    path: 'boards/join',
    component: BoardJoinComponent,
    canActivate: [authGuard],
  },
  {
    path: 'account',
    component: AccountComponent,
    canActivate: [authGuard],
  },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'error', component: InternalServerErrorComponent },
  { path: '**', component: NotFoundComponent },
];
