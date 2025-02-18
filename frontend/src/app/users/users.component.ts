import { Component, NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormControl, FormGroup } from '@angular/forms';
import { ApiService } from '../services/api.service';
import { PaginationComponent } from '../pagination/pagination.component';
import { FilterComponent } from '../filter/filter.component';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { PersonService } from '../services/person/person.service';
import { RoleTypeEnum } from '../models/enums/role-type.enum';
import { GroupTypeEnum } from '../models/enums/group-type.enum';
import { HttpClient } from '@angular/common/http';
import { RealTimeService } from '../services/real-time/real-time.service';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, PaginationComponent, FilterComponent],
  templateUrl: './users.component.html',
  styleUrls: ['./users.component.css']
})
export class UsersComponent {
  //The users are actually people
  users: any[] = [];
  filteredUsers: any[] = [];
  userAccounts: any[] = [];
  filteredUserAccounts: any[] = [];
  errors: string[] = [];
  lastFilterTerm = '';

  roleTypes = Object.values(RoleTypeEnum);
  groupTypes = Object.values(GroupTypeEnum);

  confirmationMessage = '';
  actionAfterConfirmation: () => void = () => { };

  userForm = new FormGroup({
    name: new FormControl(''),
    email: new FormControl(''),
    password: new FormControl(''),
    firstName: new FormControl(''),
    surname: new FormControl(''),
    role: new FormControl(''),
    group: new FormControl('')
    

    // first_name: new FormControl(''),
    // last_name: new FormControl(''),
    // username: new FormControl(''),
    // password: new FormControl('')
  });


  constructor(private apiService: ApiService,
      private authService: AuthService,
       private router: Router,
       private http: HttpClient,
       private realTimeService: RealTimeService,
       private ngZone: NgZone) {
    this.fetchUsers();
    this.loadAllUserAccounts();

    // Subscribe to the refresh event and re-fetch events on refresh
    this.realTimeService.onRefresh((data) => {
      console.log('Refresh event received:', data);
      // Re-enter Angular zone to update the BehaviorSubject
      this.ngZone.run(() => {
        this.fetchUsers();
        this.loadAllUserAccounts();
      });
    });
  }

  fetchUsers() {
    this.apiService.get('people').subscribe((data) => {
      this.users = data.reverse();
      this.refreshUsers(this.lastFilterTerm);
    });
    
  }

  loadAllUserAccounts() {
    this.apiService.get('users').subscribe((data) => {
      this.userAccounts = data;
      console.log(this.userAccounts);
    });
  }

  getUserForAccount(accountId: number) {
    console.log(this.userAccounts.find(userAccounts => userAccounts.id === accountId));
    return this.userAccounts.find(userAccounts => userAccounts.id === accountId);
  }



  createUser() {
    this.errors = [];
    //this solves the issue of the internal server throwing an error on manager with role
    if (this.checkIfAllFieldsAreFilled(this.userForm.value)) {

      if (this.userForm.value.role === RoleTypeEnum.MANAGER){
        this.userForm.value.group = null;
      }
      if (this.userForm.value.role === RoleTypeEnum.DEVELOPER && this.userForm.value.group === null){
        this.userForm.value.group = GroupTypeEnum.GREEN;
      }
      this.apiService.post('users', this.userForm.value).subscribe({
        next: (_) => {
          this.userForm.reset();
          this.fetchUsers();
          (document.getElementById('closeModalButton') as HTMLButtonElement).click();
        }, error: (error) => {
          error.error.errors.forEach((error: any) => {
            this.errors.push(error.msg);
          });
        }
      });
    }
    //this.resetCreateForm();
  }

  checkIfAllFieldsAreFilled(value: Partial<{ name: string | null; email: string | null; password: string | null; firstName: string | null; surname: string | null; role: string | null; group: string | null; }>) {
    if (value.name === null || value.email === null || value.password === null || value.firstName === null || value.surname === null || value.role === null) {
      this.errors.push('All fields except group are required');
      return false;
    }
    return true;
  }

  resetCreateForm() {
    this.userForm.reset();
    this.errors = [];
  }

  //Users contains the people, trough them we get to the user with UserId
  //Base Id is Person Id
  deleteUser(id: number) {
    const user = this.users.find(user => user.id === id);
    console.log(user);
    this.confirmationMessage = `delete ${user.firstName} ${user.surname}`;
    this.actionAfterConfirmation = () => {
      this.apiService.delete(`users/${user.UserId}`).subscribe(() => {
        this.fetchUsers();
      });
    }
  }

  currentPage = 1;
  itemsPerPage = 5;
  get paginatedUsers() {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    const endIndex = startIndex + this.itemsPerPage;
    return this.filteredUsers.slice(startIndex, endIndex);
  }

  onPageChange(page: number): void {
    this.currentPage = page;
  }

  onFilterChange(filterTerm: string) {
    this.lastFilterTerm = filterTerm;
    this.currentPage = 1;
    this.refreshUsers(filterTerm);
  }
  //works
  refreshUsers(filterTerm: string) {
    const lowerFilter = filterTerm.toLowerCase();
    if (filterTerm) {
      this.filteredUsers = this.users.filter(user =>
        (user.firstName + " " + user.surname).toLowerCase().includes(lowerFilter) ||
        this.getUserForAccount(user.UserId).name.toLowerCase().includes(lowerFilter)
      );
    } else {
      this.filteredUsers = this.users;
    }
  }




}



