import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';

class PlacesDetails extends StatefulWidget {

  final String apiKey = 'AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc';
  @override
  _PlacesDetailsState createState() => _PlacesDetailsState();

}
class _PlacesDetailsState extends State<PlacesDetails> {
  String name, formattedAddress, formattedPhoneNumber, website, photos;

  getName(name) {
    this.name = name;
  }

  getFormattedAddress(formattedAddress) {
    this.formattedAddress = formattedAddress;
  }

  getFormattedPhoneNumber(formattedPhoneNumber) {
    this.formattedPhoneNumber = formattedPhoneNumber;
  }

  getWebsite(website) {
    this.website = website;
  }

  getPhotos(photos) {
    this.photos = photos;
  }

  final ScrollController listScrollController = new ScrollController();

  CollectionReference collection = FirebaseFirestore.instance.collection('Places');
  Future fetchDetails() async {
    collection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Flexible(
              flex: 24,
              child: ListView.builder(
                controller: listScrollController,
                padding: const EdgeInsets.all(12.0),
                itemBuilder: (context, index) {
                  //getIt();
                  return StreamBuilder<QuerySnapshot>(
                    stream: collection.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return new Text('Loading...');
                        default:
                          return new ListView(
                            shrinkWrap: true,
                            children: snapshot.data.docs
                                .map((DocumentSnapshot document) {
                                  String doc = document.toString();
                                  getPlace(doc);
                              return new ListTile(
                                  title: new Text(places.),
                                  subtitle: new Text("Phone Number: " + document['phoneNumber'] + "\nEmail: "  + document['email']),
                                  onTap: (){
                                    firstNameField.text = document['firstName'];
                                    lastNameField.text = document['lastName'];
                                    phoneNumberField.text = document['phoneNumber'];
                                    emailField.text = document['email'];
                                    getFirstName(document['firstName']);
                                    getLastName(document['lastName']);
                                    getPhoneNumber(document['phoneNumber']);
                                    getEmail(document['email']);
                                    print(document['firstName'] + " " + document['lastName']);
                                  }
                              );
                            }).toList(),
                          );
                      }
                    },
                  );
                },
              )),

        )

    );
  }


}


final places = GoogleMapsPlaces(apiKey: Platform.environment['AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc']);
Future<PlacesDetailsResponse> getPlace(String placeID) async{

  final places = new GoogleMapsPlaces(apiKey: "AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc");

  PlacesDetailsResponse response = await places.getDetailsByPlaceId(placeID);

  name = response.result.name;
  String formattedAddress = response.result.formattedAddress;
  String formattedPhoneNumber = response.result.formattedPhoneNumber;
  String website = response.result.website;

  print(response.result.name);
  print(response.result.formattedAddress);
  print(response.result.formattedPhoneNumber);
  print(response.result.website);
  print(response.result.photos);

  return response;

}



