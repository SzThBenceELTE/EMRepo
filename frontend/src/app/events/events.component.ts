import { Component, } from '@angular/core';
import { ApiService } from '../services/api.service';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';
import { IDropdownSettings, NgMultiSelectDropDownModule } from 'ng-multiselect-dropdown';
import { FilterComponent } from '../filter/filter.component';
import { PaginationComponent } from '../pagination/pagination.component';
import { filter, Observable } from 'rxjs';
import { StatusTypeEnum } from '../models/enums/status-type.enum';
import { EventTypeEnum } from '../models/enums/event-type.enum';
import { GroupTypeEnum } from '../models/enums/group-type.enum';

/*
  TODO: The enum types are not saved on my server, I'll have to switch them out completely
*/

@Component({
  selector: 'app-events',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, NgMultiSelectDropDownModule, FilterComponent, PaginationComponent],
  templateUrl: './events.component.html',
  styleUrl: './events.component.css'
})
export class EventsComponent {
  userStatuses = Object.values(StatusTypeEnum);
  EventTypeEnum = Object.values(EventTypeEnum);
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

  eventsDropdownSettings: IDropdownSettings = {
    singleSelection: true,
    idField: 'item_id',
    textField: 'item_text',
    itemsShowLimit: 3,
    closeDropDownOnSelection: true // Optional: close the dropdown after selection
  };

  teamsInDropdownFormat: { item_id: number, item_text: string }[] = [];
  eventsInDropdownFormat: { item_id: number | null, item_text: string }[] = [];
  typesInDropdownFormat: string[] = [];
  

  selectedEvent: any = {
    users: {
      pending: [] as any[],
      accepted: [] as any[],
      applied : [] as any[],
      rejected: [] as any[],
    }
  };

  currentEvent: any = {
    name: '',
    teams: [],
    startTime: '',
    endTime: '',
    location: '',
    description: '',
    type: '',
    startDate: '',
    endDate: '',
    maxParticipants: '',
    imagePath: '',
    parentId: '',
  }

  //elements of the form here
  eventForm = new FormGroup({
    name: new FormControl(''),
    teams: new FormControl([]),
    startTime: new FormControl(''),
    endTime: new FormControl(''),
    location: new FormControl(''),
    description: new FormControl(''),
    type: new FormControl(''),
    startDate: new FormControl(''),
    endDate: new FormControl(''),
    maxParticipants: new FormControl(''),
    imagePath: new FormControl(''),
    parentId: new FormControl(''),

     // limit: new FormControl(''),
    //date: new FormControl(''),
    // subevent_name: new FormControl(''),
    // subevent_limit: new FormControl(''),
    // subevent_startTime: new FormControl(''),
    // subevent_endTime: new FormControl(''),
    // subevent_location: new FormControl(''),
    // subevent_description: new FormControl(''),

    // name: new FormControl(''),
    

  });
  //probably the image
  selectedFile: File | null = null;

  constructor(private apiService: ApiService, protected authService: AuthService) {
    this.fetchEvents();
    this.apiService.get('teams').subscribe((teams) => {
      this.teamsInDropdownFormat = teams.map((team: any) => { return { item_id: team.id, item_text: team.name } });
    });
    this.apiService.get('events').subscribe((events) => {
      this.eventsInDropdownFormat = events.map((event: any) =>{console.log(event.parentId); return event}).filter((event: any) => {return event.parentId == null}).map((event: any) => { return { item_id: event.id, item_text: event.name } });
      this.eventsInDropdownFormat.push({ item_id: null, item_text: 'None' });
    });
    for (const type of Object.values(EventTypeEnum)) {
      this.typesInDropdownFormat.push(type);
    }

    

  }
  //fetch all events, refresh the page
  fetchEvents() {
    this.apiService.get('events').subscribe((data) => {
      this.events = data.reverse();
      console.log(this.events);
      this.refreshEvents(this.lastFilterTerm);
    });
  }
  //current one
  setSelectedEvent(event_id: number) {
    this.selectedEvent = this.events.find(event => event.id === event_id);
    this.currentEvent = this.events.find(event => event.id === event_id);
    console.log(this.selectedEvent);
  }
  //applies changes after editing
  fetchEditEvent(event_id: number) {
    this.errors = [];
    this.eventForm.reset();
    this.setSelectedEvent(event_id);

    if (!!this.selectedEvent.subevent_name !== this.subEventCollapse) {
      (document.getElementById('subEventCreationButton') as HTMLButtonElement).click();
    }

    this.selectedFile = null;
    this.imagePreviewSrc = null;
    this.newEventSubmit = false;

    this.eventForm.patchValue({
      name: this.selectedEvent.name,
      location: this.selectedEvent.location,
      description: this.selectedEvent.description,
      maxParticipants: this.selectedEvent.maxParticipants,
      startDate: new Date(Date.parse(this.selectedEvent.startDate)).toISOString().slice(0, 10),
      startTime: new Date(Date.parse(this.selectedEvent.startDate)).toISOString().slice(11, 16),
      endDate: new Date(Date.parse(this.selectedEvent.endDate)).toISOString().slice(0, 10),
      endTime: new Date(Date.parse(this.selectedEvent.endDate)).toISOString().slice(11, 16),
      
      // startTime: this.selectedEvent.startDate.format('HH:mm'),
    });

    // this.eventForm.patchValue(this.selectedEvent);
    // this.eventForm.patchValue({
    //   teams: this.selectedEvent.teams.map((team: any) => ({
    //     item_id: team.id,
    //     item_text: team.name
    //   }))
    // });
  }
  //fetch after creation
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
  //big data dump for event creation
  submitEvent() {
    // this.errors = [];
    // const formData = new FormData();
    // formData.append('name', this.eventForm.get('name')?.value || '');
    // formData.append('limit', this.eventForm.get('limit')?.value || '');
    // formData.append('teams', JSON.stringify(this.eventForm.get('teams')?.value ?? []));
    // formData.append('date', this.eventForm.get('date')?.value || '');
    // formData.append('location', this.eventForm.get('location')?.value || '');
    // formData.append('description', this.eventForm.get('description')?.value || '');
    // formData.append('startTime', this.eventForm.get('startTime')?.value || '');
    // formData.append('endTime', this.eventForm.get('endTime')?.value || '');
    // formData.append('subevent_name', this.eventForm.get('subevent_name')?.value || '');
    // formData.append('subevent_limit', this.eventForm.get('subevent_limit')?.value || '');
    // formData.append('subevent_startTime', this.eventForm.get('subevent_startTime')?.value || '');
    // formData.append('subevent_endTime', this.eventForm.get('subevent_endTime')?.value || '');
    // formData.append('subevent_location', this.eventForm.get('subevent_location')?.value || '');
    // formData.append('subevent_description', this.eventForm.get('subevent_description')?.value || '');

    this.errors = [];
    const formData = new FormData();
  
    // Append simple fields
    formData.append('name', this.eventForm.get('name')?.value || '');
    console.log(this.eventForm.get('name')?.value);
    const typeValue = this.eventForm.get('type')?.value;
    console.log(typeValue?.toString());
    formData.append('maxParticipants', this.eventForm.get('maxParticipants')?.value?.toString() || '');
    console.log(this.eventForm.get('maxParticipants')?.value?.toString());
    formData.append('type', typeValue?.toString() || EventTypeEnum.MEETING.toString());
    console.log(typeValue?.toString());
    const selectedTeams = this.eventForm.get('teams')?.value; // This is an array of objects
    
    // Map over the selected items to extract only the item_id values
    const teamIds = Array.isArray(selectedTeams)
      ? selectedTeams.map((team: { item_id: number; item_text: string }) => team.item_id)
      : [];
    
    // formData.append('teams', JSON.stringify(teamIds));

    for (const team of teamIds) {
      formData.append('teams', team.toString());
    }

    console.log(teamIds);

    const parent = this.eventForm.get('parentId')?.value;
    const parents = Array.isArray(parent)
     ? parent.map((event: { item_id: number | null; item_text: string }) => event.item_id)[0]
     : null;

    
    if (parents != null) {
      formData.append('parentId', JSON.stringify(parents));
      console.log(parents + " is the parent");
    }
    
    
    



    formData.append('location', this.eventForm.get('location')?.value || '');
    console.log(this.eventForm.get('location')?.value);
    formData.append('description', this.eventForm.get('description')?.value || '');
    console.log(this.eventForm.get('description')?.value);
    // Retrieve date and time fields from the form
    const startDateStr = this.eventForm.get('startDate')?.value; // Expected format: "YYYY-MM-DD"
    const startTimeStr = this.eventForm.get('startTime')?.value; // Expected format: "HH:mm"
    const endDateStr = this.eventForm.get('endDate')?.value;     // Expected format: "YYYY-MM-DD"
    const endTimeStr = this.eventForm.get('endTime')?.value;       // Expected format: "HH:mm"
  
    // Combine start date and time if available
    let fullStartDateTime = '';
    if (startDateStr && startTimeStr) {
      // Construct a datetime string and create a Date object
      const startDateTime = new Date(`${startDateStr}T${startTimeStr}`);
      console.log(startDateTime);
      fullStartDateTime = startDateTime.toISOString(); // e.g., "2025-02-05T08:30:00.000Z"
    }
  
    // Combine end date and time if available
    let fullEndDateTime = '';
    if (endDateStr && endTimeStr) {
      const endDateTime = new Date(`${endDateStr}T${endTimeStr}`);
      fullEndDateTime = endDateTime.toISOString();
    }
  
    // Append combined datetimes to the FormData
    formData.append('startDate', fullStartDateTime);
    formData.append('endDate', fullEndDateTime);


    let gr = console.log("Group type enum: " + Object.values(GroupTypeEnum));


    // for(const group in Object.values(GroupTypeEnum)) {
    //   console.log("Found group: " + group);
    //   formData.append('groups', group);  //for some reason this is just an empty []
    // }

    formData.append('groups', 'RED');
    formData.append('groups', 'GREEN');
    formData.append('groups', 'BLUE');
    formData.append('groups', 'YELLOW');


    
    //Parent Id doesn't save corrrectly, everything else seems to be good
    // const parent = JSON.stringify(this.eventForm.get('parentId')?.value);
    // console.log("Parent value:" + parent);
    // if (this.eventForm.get('parentId')?.value != null && this.eventForm.get('parentId')?.value?.event_id == null) {
    //   formData.append('parentId', null);
    // }
    // formData.append('parentId', parent || '');
  
    // Append image if one is selected
    if (this.selectedFile) {
      formData.append('image', this.selectedFile);
    }
    
  
    // Decide whether to create a new event or update an existing one
    let func: () => Observable<any>;
    if (this.newEventSubmit) {
      func = () => this.apiService.post('events', formData);
    } else {
      func = () => this.apiService.put(`events/${this.selectedEvent.id}`, formData);
    }
  
    // Call the API and subscribe to the result
    func().subscribe({
      next: (_) => {
        // Close the modal, reset the form, and refresh events list
        (document.getElementById('closeModalButton') as HTMLButtonElement).click();
        this.eventForm.reset();
        this.fetchEvents();
      },
      error: (error) => {
        error.error.errors.forEach((err: any) => {
          this.errors.push(err.msg);
        });
      },
    });
  }

  //event deletion
  deleteEvent() {
    this.confirmationMessage = `delete ${this.selectedEvent.name}`;
    const team_id = this.selectedEvent.id;
    this.actionAfterConfirmation = () => {
      this.apiService.delete(`events/${team_id}`).subscribe(() => {
        this.fetchEvents();
      });
    }
  }

  //state change when new image is selected
  onImageSelected(event: any) {
    const file: File = event.target.files[0];
    if (file) {
      this.selectedFile = file;
    }
    this.imagePreviewSrc = URL.createObjectURL(file);
  }
  // deletion for the subevent
  deleteSubEvent() {
    // this.eventForm.patchValue({
    //   subevent_name: '',
    //   subevent_limit: '',
    //   subevent_startTime: '',
    //   subevent_endTime: '',
    //   subevent_location: '',
    //   subevent_description: '',
    // });

    // (document.getElementById('subEventCreationButton') as HTMLButtonElement).click();
  }
  //checker if subevent exists
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
  //simple refresh for events
  refreshEvents(filterTerm: string) {
    if (!filterTerm) {
      this.filteredEvents = this.events;
      return;
    }
    console.log(filterTerm);

    this.filteredEvents = this.events.filter(event => {
      console.log(event);
      return event.name.toLowerCase().includes(filterTerm.toLowerCase()) //||
        /*his.userStatuses.some(status =>
          event.users[status].some((user: any) =>
        (user.first_name + " " + user.last_name).toLowerCase().includes(filterTerm.toLowerCase())
          )
        ) ||*/
        //event.teams.some((team: any) => team.name.toLowerCase().includes(filterTerm.toLowerCase()));
    });
    console.log(this.filteredEvents);
  }

  getImagePath(event: any) {
    return event.imagePath ? `http://localhost:3000/${event.imagePath}` : 'http://localhost:3000/uploads/default/image3-min-1.webp';
  }







}