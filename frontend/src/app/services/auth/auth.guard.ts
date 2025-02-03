// src/app/services/auth/auth.guard.ts

import { Injectable } from '@angular/core';
import {
  CanActivate,
  ActivatedRouteSnapshot,
  RouterStateSnapshot,
  UrlTree,
  Router,
} from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';
import { map, take } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean | UrlTree> {
    return this.authService.currentPerson$.pipe(
      take(1), // Take the current value and complete
      map((person) => {
        if (person) {
          // User is logged in
          return true;
        } else {
          // User is not logged in, redirect to unauthorized page
          return this.router.createUrlTree(['/unauthorized']);
        }
      })
    );
  }
}