import { Component } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
    selector: 'app-register',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule],
    templateUrl: './register.component.html',
    styleUrl: './register.component.css'
})
export class RegisterComponent {
  userForm = new FormGroup({
    name: new FormControl(''),
    email: new FormControl(''),
    password: new FormControl(''),
    firstName: new FormControl(''),
    surname: new FormControl(''),
    role: new FormControl('MANAGER'),
    group: new FormControl('')
  });

  constructor(private authService: AuthService, private router: Router) { }


  register() {
    this.authService.register(this.userForm.value).subscribe({
      next: () => {
        this.router.navigate(['/users']);
      }, error: (error: any) => {
        if (error.error.errors) {
          alert(error.error.errors[0].msg);
        } else {
          alert(error.error.message);
        }
      }
    });
  }
}
