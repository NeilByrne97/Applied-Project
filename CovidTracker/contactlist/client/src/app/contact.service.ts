import { Injectable } from '@angular/core';
import {Http, Headers} from '@angular/http';
import {Contact} from './contact';
import 'rxjs/add/operator/map';
import 'rxjs/Rx';
import { map } from 'rxjs/operators';

@Injectable()
export class ContactService {

  constructor(private http: Http) { }

  getContacts(){
    return this.http.get('http://localhost:3000/api/contacts/')
    .pipe(map((res: any) => res.json()));
  }

  // Add contact
  addContact(newContact: any){
    var headers = new Headers()
    headers.append('Content-Type', 'application/json')
    return this.http.post('http://localhost:3000/api/contact/', newContact, {headers:headers})
    .pipe(map((res: any) => res.json()));
  }
  
  // Delete contact
  deleteContact(id: any){
    return this.http.delete('http://localhost:3000/api/contact/' + id)
    .pipe(map((res: any) => res.json()));
  }


}
