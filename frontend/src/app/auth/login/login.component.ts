import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { ReactiveFormsModule, FormControl, FormGroup } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
    selector: 'app-login',
    imports: [CommonModule, ReactiveFormsModule],
    templateUrl: './login.component.html',
    styleUrl: './login.component.css'
})
export class LoginComponent {
  loginForm = new FormGroup({
    username: new FormControl(''),
    password: new FormControl('')
  });
  errors: string[] = [];

  constructor(private authService: AuthService, private router: Router) { }

  onLogin() {
    this.errors = [];
    this.authService.login(this.loginForm.value).subscribe({
      next: () => {
        this.router.navigate(['/users']);
      }, error: (error: any) => {
        error.error.errors.forEach((error: any) => {
          this.errors.push(error.msg);
        });
      }
    });
  }
}
