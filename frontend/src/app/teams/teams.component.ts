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
  teams: any[] = [];  //all teams loaded in for presentation
  filteredTeams: any[] = [];  //the filtered ones
  errors: string[] = [];
  usersWithoutTeam: { item_id: number, item_text: string }[] = []; //users without team are just loaded in, need to change this to reflect my users (mainly people)
  selectedTeamId: any;  //Currently selected team id - team taken from array
  lastFilterTerm = '';  //filter

  teamForm = new FormGroup({
    name: new FormControl('')
  }); //this will create the team from just a name
  selectUsersForm = new FormGroup({
    users: new FormControl([])  //this will select users to add to the team (?)
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
      console.log(this.teams);
    });
  }

  fetchUsersWithoutTeam() {
    this.apiService.get('people/noTeams').subscribe(users => {
      this.usersWithoutTeam = users.map((user: any) => { return { item_id: user.id, item_text: user.firstName + ' ' + user.surname } });
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

  //Solved until this point, continue from here

  removeUserFromTeam(team_id: number, user_id: number) {
    const team = this.teams.find(team => team.id === team_id);
    console.log(team);
    const user = team.People.find((user: any) => user.id === user_id);
    console.log(user);
    this.confirmationMessage = `remove ${user.firstName} ${user.surname} from ${team.name}`;
    this.actionAfterConfirmation = () => {
      this.apiService.delete(`teams/remove/${team_id}/${user_id}`).subscribe(() => {
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