import { Routes } from '@angular/router';
import { UsersComponent } from './users/users.component';
import { TeamsComponent } from './teams/teams.component';
import { EventsComponent } from './events/events.component';
import { LoginComponent } from './auth/login/login.component';
import { RegisterComponent } from './auth/register/register.component';
import { adminGuard } from './guards/admin.guard';

export const routes: Routes = [
    {path: 'register', component: RegisterComponent},
    {path: 'login', component: LoginComponent},
    {path: 'users', component: UsersComponent, canActivate: [adminGuard]},
    {path: 'teams', component: TeamsComponent, canActivate: [adminGuard]},
    {path: 'events', component: EventsComponent, canActivate: [adminGuard]},
    
];
