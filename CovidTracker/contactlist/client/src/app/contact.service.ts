import { Injectable } from '@angular/core';
import {Http, Headers} from '@angular/http';
import { HttpClientModule, HttpClient } from '@angular/common/http';
import {Contact} from './contact';
import { Observable, of, throwError } from 'rxjs';
import { catchError, tap, map } from 'rxjs/operators';

const apiUrl = 'http://localhost:3000/api';

@Injectable()
export class ContactService {

  constructor(private http: HttpClient) { }

  // Retrieve contacts
 /* getContacts(){
    return this.http.get('http://localhost:3000/api/contacts')
    .pipe(map(res => res.json()));
  }
*/
  getContacts(): Observable<Contact[]> {
    return this.http.get<Contact[]>(`${apiUrl}`)
      .pipe(
        tap(cases => console.log('fetched contacts')),
      );
  }

  // Add contact
  addContact(newContact: any){
    var headers = new Headers()
    headers.append('Content-Type', 'application/json')
    return this.http.post('http://localhost:3000/api/contacts', newContact, {headers:headers})
    .pipe(map(res => res.json()));
  }
  
  // Delete contact
  deleteContact(id: any){
    return this.http.delete('http://localhost:3000/api/contact' + id)
    .pipe(map(res => res.json()));
  }


}
