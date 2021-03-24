import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { ContactsComponent } from './contacts/contacts.component';
import { ContactService } from './contact.service';
import { HttpModule } from '@angular/http';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { FilterPipe } from './filter.pipe';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import {AngularMaterialModule} from './angular-material.module';



@NgModule({
  declarations: [
    AppComponent,
    ContactsComponent,
    FilterPipe
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpModule,
    HttpClientModule,
    FormsModule,
    BrowserAnimationsModule,
    AngularMaterialModule
  ],
  providers: [
    ContactsComponent,
    ContactService
  ],
  bootstrap: [
    AppComponent
  ]
})
export class AppModule { }
