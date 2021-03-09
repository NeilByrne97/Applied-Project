class FirebaseContactDetails {
  String firstName;
  String lastName;
  String phoneNumber;
  String email;

  FirebaseContactDetails({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.email,
  });

  FirebaseContactDetails.fromJson(Map<String, dynamic> json){
    firstName = json['firstName'];
    lastName = json['lastName'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
  }
}