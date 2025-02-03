import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, catchError } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiURL = 'http://localhost:3000/api';

  constructor(private http: HttpClient) { }


  get(endpoint: string, params: any = {}): Observable<any> {
    const token = localStorage.getItem('auth_token');

    let httpHeaders = new HttpHeaders({ 'Authorization': 'Bearer ' + token });

    const httpParams = new HttpParams({ fromObject: params });

    return this.http.get(`${this.apiURL}/${endpoint}`, { params: httpParams, headers: httpHeaders });
  }
  post(endpoint: string, body: any = {}): Observable<any> {
    const token = localStorage.getItem('auth_token');

    let httpHeaders = new HttpHeaders({ 'Authorization': 'Bearer ' + token });

    return this.http.post(`${this.apiURL}/${endpoint}`, body, { headers: httpHeaders });
  }

  put(endpoint: string, body: any = {}): Observable<any> {
    const token = localStorage.getItem('auth_token');

    let httpHeaders = new HttpHeaders({ 'Authorization': 'Bearer ' + token });

    return this.http.put(`${this.apiURL}/${endpoint}`, body, { headers: httpHeaders });
  }



  delete(endpoint: string): Observable<any> {

    const token = localStorage.getItem('auth_token');

    let httpHeaders = new HttpHeaders({ 'Authorization': 'Bearer ' + token });

    return this.http.delete(`${this.apiURL}/${endpoint}`, { headers: httpHeaders });
  }
}
