import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:url_launcher/url_launcher.dart';

import 'MainPage.dart';

class PlacesDetails extends StatefulWidget {
  final String apiKey = 'AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc';

  @override
  _PlacesDetailsState createState() => _PlacesDetailsState();
}

class _PlacesDetailsState extends State<PlacesDetails> {
  String name, formattedAddress, formattedPhoneNumber, website, photos;
  String placeID;

  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String uid;

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
  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  Future fetchDetails() async {
    usersCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
      });
    });
  }

  void _getUID() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    this.uid = uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(' Places You\'ve Been  '),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MainPage()));
              getPlace();
            },
            child: Icon(
              Icons.arrow_back, // add custom icons also
            ),
          ),
        ),
        body: Center(
          child: Flexible(
              flex: 24,
              child: ListView.builder(
                controller: listScrollController,
                padding: const EdgeInsets.all(12.0),
                itemBuilder: (context, index) {
                  _getUID();
                  return StreamBuilder<QuerySnapshot>(
                    stream: usersCollection.doc(uid).collection('Places').snapshots(),
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

  getPlace() async {
    final places =
        new GoogleMapsPlaces(apiKey: "AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc");
    String apiKey = "AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc";
    String place = "ChIJ_aKF2fqWW0gRDLLSSGNL_hc";
    PlacesDetailsResponse response = await places.getDetailsByPlaceId(place);

    name = response.result.name;
    formattedAddress = response.result.formattedAddress;
    formattedPhoneNumber = response.result.formattedPhoneNumber;
    website = response.result.website;

    var photoRef = response.result.photos[0].photoReference;
    print(photoRef);


    final baseUrl = "https://maps.googleapis.com/maps/api/place/photo";
    final maxWidth = "400";
    final maxHeight = "200";
    final url = "$baseUrl?maxwidth=$maxWidth&maxheight=$maxHeight&photoreference=$photoRef&key=$apiKey";

    //https://maps.googleapis.com/maps/api/place/photo?maxwidth=$400&maxheight=$200&photoreference=$ATtYBwL-RF_YV0Ry5VPZhtpMTTY2Kd2nMtwh-XUYMqi74cF8D65ty6HYffJw1dhAHud4jqJ26bya419iD5_eP0J5iSyIDLcp7Ksa_inIlbvxLb5ypvaIe0Z3ssbBDf5nt9b_1lP6eLzE3Z2_Jkmu6nTDeqKv0wyHH2g2vCVpEAfDqF3UHbNh&key=$AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc
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
