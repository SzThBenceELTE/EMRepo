import { Component, } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormControl, FormGroup } from '@angular/forms';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';
import { IDropdownSettings, NgMultiSelectDropDownModule } from 'ng-multiselect-dropdown';
import { FilterComponent } from '../filter/filter.component';


@Component({
  selector: 'app-teams',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, NgMultiSelectDropDownModule, FilterComponent],
  templateUrl: './teams.component.html',
  styleUrls: ['./teams.component.css']
})
export class TeamsComponent {
  teams: any[] = [];
  filteredTeams: any[] = [];
  errors: string[] = [];
  usersWithoutTeam: { item_id: number, item_text: string }[] = [];
  selectedTeamId: any;
  lastFilterTerm = '';

  teamForm = new FormGroup({
    name: new FormControl('')
  });
  selectUsersForm = new FormGroup({
    users: new FormControl([])
  });

  actionAfterConfirmation = () => { }
  dropdownSettings: IDropdownSettings = {
    allowSearchFilter: true,
    idField: 'item_id',
    textField: 'item_text',
    selectAllText: 'Select All',
    unSelectAllText: 'Deselect All',
    itemsShowLimit: 3,
  };
  confirmationMessage = '';

  constructor(private apiService: ApiService, protected authService: AuthService) {
    this.fetchTeams();
  }

  fetchTeams() {
    this.apiService.get('teams').subscribe((data) => {
      this.teams = data;
      this.refreshTeams(this.lastFilterTerm);
    });
  }

  fetchUsersWithoutTeam() {
    this.apiService.get('people/managers').subscribe(users => {
      this.usersWithoutTeam = users.map((user: any) => { return { item_id: user.id, item_text: user.first_name + ' ' + user.last_name } });
    });
  }

  createTeam() {
    this.errors = [];
    this.apiService.post('teams', this.teamForm.value).subscribe({
      next: (_) => {
        this.teamForm.reset();
        this.fetchTeams();
        (document.getElementById('closeModalButton') as HTMLButtonElement).click();
      }, error: (error) => {
        error.error.errors.forEach((error: any) => {
          this.errors.push(error.msg);
        });
      }
    });
  }

  deleteTeam(team_id: number) {
    const team = this.teams.find(team => team.id === team_id);
    this.confirmationMessage = `delete ${team.name}`;
    this.actionAfterConfirmation = () => {
      this.apiService.delete(`teams/${team_id}`).subscribe(() => {
        this.fetchTeams();
      });
    }
  }

  removeUserFromTeam(team_id: number, user_id: number) {
    const team = this.teams.find(team => team.id === team_id);
    const user = team.users.find((user: any) => user.id === user_id);
    this.confirmationMessage = `remove ${user.first_name} ${user.last_name} from ${team.name}`;
    this.actionAfterConfirmation = () => {
      this.apiService.delete(`teams/${team_id}/users/${user_id}`).subscribe(() => {
        this.fetchTeams();
      });
    }
  }

  addUsersToTeam(): void {
    this.apiService.post(`teams/${this.selectedTeamId}/users`, { 'user_ids': this.selectUsersForm.get('users')?.value?.map((user: any) => user.item_id) }).subscribe(() => {
      this.fetchTeams();
      this.fetchUsersWithoutTeam();
      this.selectUsersForm.reset();
      (document.getElementById('closeModalButton') as HTMLButtonElement).click();
    }
    );

  }

  setSelectedTeam(team_id: any) {
    this.selectedTeamId = team_id;
    this.fetchUsersWithoutTeam();
  }

  onFilterChange(filterTerm: string) {
    this.lastFilterTerm = filterTerm;
    this.refreshTeams(filterTerm);

  }

  refreshTeams(filterTerm: string) {
    if (filterTerm) {
      this.filteredTeams = this.teams.filter(team =>
        team.users.some((user: any) => (user.first_name + " " + user.last_name).toLowerCase().includes(filterTerm.toLowerCase())) ||
        team.name.toLowerCase().includes(filterTerm.toLowerCase())
      );
    } else {
      this.filteredTeams = this.teams;
    }
  }
}