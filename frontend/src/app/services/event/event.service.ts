import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { EventTypeEnum } from "../../models/enums/event-type.enum";
import { HttpParams } from '@angular/common/http';
import { EventModel } from "../../models/event.model";
//import { GroupModel } from "../../models/group.model";
import { GroupTypeEnum } from "../../models/enums/group-type.enum";

@Injectable({
    providedIn: 'root'
})
export class EventService {
    private apiUrl = 'http://localhost:3000/api/events';

    constructor(private http: HttpClient) {}

    getEvents(): Observable<EventModel[]> {
        return this.http.get<EventModel[]>(this.apiUrl);
    }

    getAllEvents(): Observable<EventModel[]> {
        return this.http.get<EventModel[]>(`${this.apiUrl}/all`);
    }

    getAllAndPastEvents(): Observable<EventModel[]> {
        return this.http.get<EventModel[]>(`${this.apiUrl}/allandpast`);
    }

    // getGroups(): Observable<GroupModel[]> {
    //     return this.http.get<GroupModel[]>(`${this.apiUrl}/groups`);
    //   }

    createEvent(eventData: FormData): Observable<any> {
        console.log(eventData);
        return this.http.post(this.apiUrl, eventData);
    }

    getEvent(id: number): Observable<any> {
        return this.http.get(`${this.apiUrl}/${id}`);
    }

    updateEvent(id: number, eventData : FormData): Observable<any> {
        return this.http.put(`${this.apiUrl}/${id}`, eventData);
    }

    deleteEvent(id: number): Observable<any> {
        return this.http.delete(`${this.apiUrl}/${id}`);
    }

    joinEvent(eventId: number, personId: number): Observable<any> {
        return this.http.post(`${this.apiUrl}/join`, { eventId, personId });
    }
      
    leaveEvent(eventId: number, personId: number): Observable<any> {
        return this.http.post(`${this.apiUrl}/leave`, { eventId, personId });
    }
    getParentEvents(): Observable<EventModel[]> {
        const params = new HttpParams().set('parentId', 'null');
        return this.http.get<EventModel[]>(this.apiUrl, { params });
    }
}