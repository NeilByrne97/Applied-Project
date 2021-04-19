import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacesDetails extends StatefulWidget {
  final String apiKey = 'AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc';

  @override
  _PlacesDetailsState createState() => _PlacesDetailsState();
}

class _PlacesDetailsState extends State<PlacesDetails> {
  String name, formattedAddress, formattedPhoneNumber, website, photos;
  String placeID;

  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

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
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Places');

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
        appBar: AppBar(
          title: Text(' Places You\'ve Been  '),
        ),
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
                              return new ListTile(
                                title: new Text(document['name']),
                                subtitle: new Text(
                                    document['formattedAddress'] +
                                        "\n" +
                                        document['formattedPhoneNumber'] +
                                        "\n" +
                                        document['website']),
                                onTap: () {
                                  name = document['name'];
                                  formattedPhoneNumber =
                                      document['formattedPhoneNumber'];
                                  getName(document['name']);
                                  getFormattedPhoneNumber(
                                      document['formattedPhoneNumber']);
                                  _contactAlert();
                                },
                              );
                            }).toList(),
                          );
                      }
                    },
                  );
                },
              )),
        ));
  }

  getPlace(String placeID) async {
    final places =
        new GoogleMapsPlaces(apiKey: "AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc");
    String place = "ChIJ_aKF2fqWW0gRDLLSSGNL_hc";

    PlacesDetailsResponse response = await places.getDetailsByPlaceId(place);

    name = response.result.name;
    formattedAddress = response.result.formattedAddress;
    formattedPhoneNumber = response.result.formattedPhoneNumber;
    website = response.result.website;

    var photo = response.result.photos;

    return response;
  }

  Future<void> _contactAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact ' + name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('How would you like to contact ' + name + "?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Call'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
                _service.call(formattedPhoneNumber);
              },
            ),
            TextButton(
              child: Text('SMS'),
              onPressed: () {
                _service.sendSms(formattedPhoneNumber);
              },
            ),
          ],
        );
      },
    );
  }
}

class CallsAndMessagesService {
  void call(String number) => launch("tel:$number");

  void sendSms(String number) => launch("sms:$number");

  void sendEmail(String email) => launch("mailto:$email");
}

GetIt locator = GetIt();

void setupLocator() {
  locator.registerSingleton(CallsAndMessagesService());
}