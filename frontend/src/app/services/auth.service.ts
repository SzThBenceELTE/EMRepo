import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { jwtDecode } from 'jwt-decode';
import { tap, catchError } from 'rxjs';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  constructor(private apiService: ApiService, private router : Router) { }

  private tokenKey = 'auth_token';

  login(data: any): any {
    return this.apiService.post("users/login", data).pipe(
      tap((data) => {
        console.log(data);
        console.log(jwtDecode(data['token']));
        localStorage.setItem(this.tokenKey, data['token']);
      })
    )
  }

  register(data: any): any {
    return this.apiService.post("users", data).pipe(
      tap((data) => {
        localStorage.setItem(this.tokenKey, data['token']);
      })
    )
  }

  private decodeToken(): any | null {
    const token = localStorage.getItem(this.tokenKey);
    return token ? jwtDecode(token) : null;
  }
  
  get isLoggedIn(): boolean {
    return !!localStorage.getItem(this.tokenKey);
  }
  
  get isAdmin(): boolean {
    return this.decodeToken()?.role == "MANAGER";
  }
  
  get username(): string {
    return this.decodeToken()?.username;
  }

  get firstName(): string {
    return this.decodeToken()?.firstName;
  }

  get surname(): string {
    return this.decodeToken()?.surname;
  }
  
  get teamname(): string {
    return this.decodeToken()?.team_name;
  }
  
  get userId(): string {
    return this.decodeToken()?.userId;
  }
  
  get teamId(): string {
    return this.decodeToken()?.team_id;
  }
  
  logout(): void {
    localStorage.removeItem(this.tokenKey);
    this.router.navigate(['/login']);
  }
  

}
