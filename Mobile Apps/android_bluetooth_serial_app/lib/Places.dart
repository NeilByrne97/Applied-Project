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
  String placeID;

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
                                  print("Doc is " + doc);
                                  getPlace(doc);
                                  print(name);
                                  print(formattedAddress);
                                  print(formattedPhoneNumber);
                                  print(website);
                              return new ListTile(
                                  title: new Text(getName(name)),
                                  subtitle: new Text(getFormattedAddress(formattedAddress) + "\n" + getFormattedPhoneNumber(formattedPhoneNumber) + "\n" + getWebsite(website)),

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

  getPlace(String placeID) async{

    final places = new GoogleMapsPlaces(apiKey: "AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc");
    String place = "ChIJ_aKF2fqWW0gRDLLSSGNL_hc";

    PlacesDetailsResponse response = await places.getDetailsByPlaceId(place);

    name = response.result.name;
    formattedAddress = response.result.formattedAddress;
    formattedPhoneNumber = response.result.formattedPhoneNumber;
    website = response.result.website;

    print("Future " + name);
    print("Future " + formattedAddress);
    print("Future " + formattedPhoneNumber);
    print("Future " + website);


    return response;

  }
}





