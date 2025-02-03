import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { PersonModel } from "../../models/person.model";
import { RoleTypeEnum } from "../../models/enums/role-type.enum";
import { GroupTypeEnum } from "../../models/enums/group-type.enum";

@Injectable({
    providedIn: 'root'
})
export class PersonService {
    private apiUrl = 'http://localhost:3000/api/people';

    constructor(private http: HttpClient) {}

    getPersons(): Observable<any> {
        return this.http.get(this.apiUrl);
    }

    createPerson(person: { firstName: string; surname: string; role: RoleTypeEnum; group: GroupTypeEnum | undefined }): Observable<any> {
        return this.http.post(this.apiUrl, person);
    }

    getPerson(id: number): Observable<any> {
        return this.http.get(`${this.apiUrl}/${id}`);
    }

    updatePerson(id: number, person: { firstName: string; surname: string; role: RoleTypeEnum; group: GroupTypeEnum | undefined }): Observable<any> {
        return this.http.put(`${this.apiUrl}/${id}`, person);
    }

    deletePerson(id: number): Observable<any> {
        return this.http.delete(`${this.apiUrl}/${id}`);
    }
}