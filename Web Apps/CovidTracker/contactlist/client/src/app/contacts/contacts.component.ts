import { Component, OnInit } from '@angular/core';
import {FormGroup,FormBuilder,Validators} from '@angular/forms';
import { ContactService} from '../contact.service';
import { Contact} from '../contact';
import {EmailService} from '../services/email.service'


@Component({
  selector: 'app-contacts',
  templateUrl: './contacts.component.html',
  styleUrls: ['./contacts.component.css'],
  providers: [ContactService]
})

export class ContactsComponent implements OnInit {
  contacts: Contact[];
  contact: Contact;
  first_name: string;
  last_name: string;
  phone: string;
  email: string;


  constructor(private contactService: ContactService,private formBuilder:FormBuilder,private emailService:EmailService) { }

  searchText: string; 
  title = 'nodeMailerApp';
  nodeMailerForm :FormGroup;


 

  sendMail(){
    alert("jjj");
    let emailr  = this.nodeMailerForm.value.emailr;
    let reqObj = {
      emailr:emailr
    }
    this.emailService.sendMessage(reqObj).subscribe(data=>{
      console.log(data);
    })
  }

  addContact(){
    const newContact ={
      first_name: this.first_name,
      last_name: this.last_name,
      phone: this.phone,
      email: this.email
    }
    this.contactService.addContact(newContact)
    .subscribe(contact =>{
      this.contacts.push(contact);

      this.contactService.getContacts() // Refresh when new contact added
      .subscribe( contacts =>
        this.contacts = contacts);
    });
  }




  deleteContact(id:any){
    var contacts = this.contacts;
    this.contactService.deleteContact(id)
      .subscribe(data =>{
          if(data.n==1){
            for(var i = 0;i< contacts.length;i++){
              if(contacts[i]._id == id){
                contacts.splice(i, 1);
              }
            }
          }
      });
  }

  updateContact(id:any){
    var contacts = this.contacts;
    this.contactService.deleteContact(id)
      .subscribe(data =>{
          if(data.n==1){
            for(var i = 0;i< contacts.length;i++){
              if(contacts[i]._id == id){
                contacts.splice(i, 1);
              }
            }
          }
      });
  }

  ngOnInit() {
    this.contactService.getContacts().subscribe( contacts =>this.contacts = contacts);
    this.nodeMailerForm = this.formBuilder.group({emailr:[null,[Validators.required]]})
  }

}
