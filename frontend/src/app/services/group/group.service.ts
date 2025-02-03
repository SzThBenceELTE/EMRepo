// // services/group/group.service.ts

// import { Injectable } from '@angular/core';
// import { HttpClient } from '@angular/common/http';
// import { Observable } from 'rxjs';
// //import { GroupModel } from '../../models/group.model';

// @Injectable({
//   providedIn: 'root',
// })
// export class GroupService {
//   private apiUrl = 'http://localhost:3000/api/groups';

//   constructor(private http: HttpClient) {}

//   getGroups(): Observable<GroupModel[]> {
//     return this.http.get<GroupModel[]>(this.apiUrl);
//   }
// }