import { Component, } from '@angular/core';
import { ApiService } from '../services/api.service';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';
import { IDropdownSettings, NgMultiSelectDropDownModule } from 'ng-multiselect-dropdown';
import { FilterComponent } from '../filter/filter.component';
import { PaginationComponent } from '../pagination/pagination.component';
import { filter, Observable } from 'rxjs';

@Component({
  selector: 'app-events',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, NgMultiSelectDropDownModule, FilterComponent, PaginationComponent],
  templateUrl: './events.component.html',
  styleUrl: './events.component.css'
})
export class EventsComponent {
  userStatuses = ['accepted', 'applied', 'rejected', 'pending'];
  events: any[] = [];
  filteredEvents: any[] = [];
  subEventCollapse = false;
  newEventSubmit = true;
  imagePreviewSrc: any = null;
  
  errors: string[] = [];
  lastFilterTerm = '';

  confirmationMessage = '';
  actionAfterConfirmation: () => void = () => { };



  dropdownSettings: IDropdownSettings = {
    idField: 'item_id',
    textField: 'item_text',
    selectAllText: 'Select All',
    unSelectAllText: 'Deselect All',
    itemsShowLimit: 3,

  };

  teamsInDropdownFormat: { item_id: number, item_text: string }[] = [];

  selectedEvent: any = {
    users: {
      pending: [] as any[],
      accepted: [] as any[],
      applied : [] as any[],
      rejected: [] as any[],
    }
  };


  eventForm = new FormGroup({
    name: new FormControl(''),
    limit: new FormControl(''),
    teams: new FormControl([]),
    date: new FormControl(''),
    startTime: new FormControl(''),
    endTime: new FormControl(''),
    location: new FormControl(''),
    description: new FormControl(''),
    subevent_name: new FormControl(''),
    subevent_limit: new FormControl(''),
    subevent_startTime: new FormControl(''),
    subevent_endTime: new FormControl(''),
    subevent_location: new FormControl(''),
    subevent_description: new FormControl(''),
  });

  selectedFile: File | null = null;

  constructor(private apiService: ApiService, protected authService: AuthService) {
    this.fetchEvents();
    // this.apiService.get('teams').subscribe((teams) => {
    //   this.teamsInDropdownFormat = teams.map((team: any) => { return { item_id: team.id, item_text: team.name } });
    // });

    

  }

  fetchEvents() {
    this.apiService.get('events').subscribe((data) => {
      this.events = data.reverse();
      this.refreshEvents(this.lastFilterTerm);
    });
  }

  setSelectedEvent(event_id: number) {
    this.selectedEvent = this.events.find(event => event.id === event_id);
  }

  fetchEditEvent(event_id: number) {
    this.errors = [];
    this.setSelectedEvent(event_id);

    if (!!this.selectedEvent.subevent_name !== this.subEventCollapse) {
      (document.getElementById('subEventCreationButton') as HTMLButtonElement).click();
    }

    this.selectedFile = null;
    this.imagePreviewSrc = this.selectedEvent.image;
    this.newEventSubmit = false;

    this.eventForm.patchValue(this.selectedEvent);
    this.eventForm.patchValue({
      teams: this.selectedEvent.teams.map((team: any) => ({
        item_id: team.id,
        item_text: team.name
      }))
    });
  }

  fetchNewEvent() {
    this.errors = [];
    this.eventForm.reset();
    if (this.subEventCollapse) {
      (document.getElementById('subEventCreationButton') as HTMLButtonElement).click();
    }
    this.selectedFile = null;
    this.imagePreviewSrc = null;
    this.newEventSubmit = true;
  }

  submitEvent() {
    this.errors = [];
    const formData = new FormData();
    formData.append('name', this.eventForm.get('name')?.value || '');
    formData.append('limit', this.eventForm.get('limit')?.value || '');
    formData.append('teams', JSON.stringify(this.eventForm.get('teams')?.value ?? []));
    formData.append('date', this.eventForm.get('date')?.value || '');
    formData.append('location', this.eventForm.get('location')?.value || '');
    formData.append('description', this.eventForm.get('description')?.value || '');
    formData.append('startTime', this.eventForm.get('startTime')?.value || '');
    formData.append('endTime', this.eventForm.get('endTime')?.value || '');
    formData.append('subevent_name', this.eventForm.get('subevent_name')?.value || '');
    formData.append('subevent_limit', this.eventForm.get('subevent_limit')?.value || '');
    formData.append('subevent_startTime', this.eventForm.get('subevent_startTime')?.value || '');
    formData.append('subevent_endTime', this.eventForm.get('subevent_endTime')?.value || '');
    formData.append('subevent_location', this.eventForm.get('subevent_location')?.value || '');
    formData.append('subevent_description', this.eventForm.get('subevent_description')?.value || '');


    if (this.selectedFile) {
      formData.append('image', this.selectedFile);
    }

    let func: () => Observable<any>;

    if (this.newEventSubmit) {
      func = () => this.apiService.post('events', formData);
    } else {
      func = () => this.apiService.put(`events/${this.selectedEvent.id}`, formData);
    }

    func().subscribe({
      next: (_) => {
        (document.getElementById('closeModalButton') as HTMLButtonElement).click();
        this.eventForm.reset();
        this.fetchEvents();
      },
      error: (error) => {
        error.error.errors.forEach((error: any) => {
          this.errors.push(error.msg);
        });
      },
    });
  }


  deleteEvent() {
    this.confirmationMessage = `delete ${this.selectedEvent.name}`;
    const team_id = this.selectedEvent.id;
    this.actionAfterConfirmation = () => {
      this.apiService.delete(`events/${team_id}`).subscribe(() => {
        this.fetchEvents();
      });
    }
  }


  onImageSelected(event: any) {
    const file: File = event.target.files[0];
    if (file) {
      this.selectedFile = file;
    }
    this.imagePreviewSrc = URL.createObjectURL(file);
  }

  deleteSubEvent() {
    this.eventForm.patchValue({
      subevent_name: '',
      subevent_limit: '',
      subevent_startTime: '',
      subevent_endTime: '',
      subevent_location: '',
      subevent_description: '',
    });

    (document.getElementById('subEventCreationButton') as HTMLButtonElement).click();
  }

  hasSubEvent() {
    return [
      this.eventForm.get('subevent_name')?.value,
      this.eventForm.get('subevent_limit')?.value,
      this.eventForm.get('subevent_location')?.value,
      this.eventForm.get('subevent_description')?.value,
    ].some(field => !!field);
  }

  currentPage = 1;
  itemsPerPage = 4;
  get paginatedEvents() {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    const endIndex = startIndex + this.itemsPerPage;
    return this.filteredEvents.slice(startIndex, endIndex);
  }

  onPageChange(page: number): void {
    this.currentPage = page;
  }


  onFilterChange(filterTerm: string) {
    this.lastFilterTerm = filterTerm;
    this.currentPage = 1;
    this.refreshEvents(filterTerm);
  }

  refreshEvents(filterTerm: string) {
    if (!filterTerm) {
      this.filteredEvents = this.events;
      return;
    }

    this.filteredEvents = this.events.filter(event => {
      return event.name.toLowerCase().includes(filterTerm.toLowerCase()) ||
        this.userStatuses.some(status =>
          event.users[status].some((user: any) =>
        (user.first_name + " " + user.last_name).toLowerCase().includes(filterTerm.toLowerCase())
          )
        ) ||
        event.teams.some((team: any) => team.name.toLowerCase().includes(filterTerm.toLowerCase()));
    });
  }





}