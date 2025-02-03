// src/app/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { PersonModel } from '../../models/person.model';
import { UserModel } from '../../models/user.model';
import { CookieService } from 'ngx-cookie-service';


@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private apiUrl = 'http://localhost:3000/api/users'; // Change to your login API endpoint

  private currentPerson: PersonModel | null = null;
  private tokenKey = 'loginToken';

  constructor(private http: HttpClient, private router: Router, private cookieService: CookieService) {
    this.currentPersonSubject = new BehaviorSubject<PersonModel | null>(
      this.getCurrentPersonFromCookie()
    );
    this.currentPerson$ = this.currentPersonSubject.asObservable();
  }

  private loginTokenSubject = new BehaviorSubject<string | null>(null);

  private currentPersonSubject = new BehaviorSubject<PersonModel | null>(null);
  public currentPerson$ = this.currentPersonSubject.asObservable();

  private currentUserSubject = new BehaviorSubject<UserModel | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  

  private getCurrentPersonFromCookie(): PersonModel | null {
    // if (!this.cookieService) {
    //   console.error('CookieService is not initialized.');
    //   return null;
    // }
    // Check if the 'currentPerson' cookie exists
    if (this.cookieService.check('currentPerson')) {
      const personString = this.cookieService.get('currentPerson');
      try {
        // Attempt to parse the cookie value as JSON
        return JSON.parse(personString) as PersonModel;
      } catch (error) {
        console.error('Error parsing currentPerson from cookie:', error);
        return null;
      }
    } else {
      // Cookie does not exist
      return null;
    }
  }
  

  setLoginToken(token: string | null) {
    this.loginTokenSubject.next(token);
  }

  getLoginToken(): Observable<string | null> {
    return this.loginTokenSubject.asObservable();
  }

  private usernameSubject = new BehaviorSubject<string | null>(null);

  setUsername(uname: string | null) {
    this.usernameSubject.next(uname);
  }

  getUsername(): Observable<string | null> {
    console.log('getUsername');
    console.log(this.usernameSubject.value);
    return this.usernameSubject.asObservable();
  }

  login(username: string, password: string) {
    return this.http
      .post<{ user: UserModel; token: string }>(`${this.apiUrl}/login`, { username, password })
      .pipe(
        tap((response) => {
          this.cookieService.set('token', response.token);
          this.cookieService.set('loginToken', response.token);
          this.cookieService.set(this.tokenKey, response.token);
          this.setCurrentUser(response.user);
          this.setCurrentPerson(response.user.Person);
        })
      );
  }

  // // Add method to get the token
  // getToken(): string | null {
  //   return localStorage.getItem('token');
  // }

  // Adjust logout to clear currentPerson
  logout() {
    localStorage.removeItem(this.tokenKey);
    this.clearCurrentUser();
    this.clearCurrentPerson();
    this.router.navigate(['/login']);
  }

  isLoggedIn(): boolean {
    if (typeof window === 'undefined') {
      return false; // SSR context, localStorage isn't available
    }
    return !!localStorage.getItem('loginToken');
  }

  getName(): string | null {
    if (typeof window === 'undefined') {
      return ""; // SSR context, localStorage isn't available
    }
    return localStorage.getItem('userName');
  }

  setCurrentPerson(person: PersonModel): void {
    this.currentPerson = person;
    this.currentPersonSubject.next(person);
    this.cookieService.set('currentPerson', JSON.stringify(person));
  }

  getCurrentPerson(): PersonModel | null {
    return this.currentPerson;
  }

  setCurrentUser(user: UserModel): void {
    this.currentUserSubject.next(user);
    this.cookieService.set('currentUser', JSON.stringify(user));
  }
  
  clearCurrentUser(): void {
    this.currentUserSubject.next(null);
    this.cookieService.delete('currentUser');
  }

  // Clear user data on logout
  clearCurrentPerson(): void {
    this.currentPerson = null;
    this.currentPersonSubject.next(null);
    this.cookieService.delete('currentPerson');
  }

  // Store the token (call this after successful login)
  storeToken(token: string) {
    this.cookieService.set(this.tokenKey, token);
  }

  // Retrieve the token
  getToken(): string | null {
    return this.cookieService.get(this.tokenKey) || null;
  }

  // Remove the token (call this on logout)
  removeToken() {
    localStorage.removeItem(this.tokenKey);
  }
  
}
