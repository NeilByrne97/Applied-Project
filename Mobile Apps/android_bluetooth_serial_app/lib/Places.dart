import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';

class PlacesDetails extends StatefulWidget {

  final String apiKey = 'AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc';
  @override
  _PlacesDetailsState createState() => _PlacesDetailsState();
}
class _PlacesDetailsState extends State<PlacesDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: Colors.blue,
                  iconSize: 50,
                  icon: const Icon(Icons.save),
                  onPressed: getPlace,
                )
              ]),
        )
    );
  }


}


final places = GoogleMapsPlaces(apiKey: Platform.environment['AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc']);
Future<void> getPlace() async{
  var sessionToken = 'xyzabc_1234';
  var res = await places.autocomplete('Amoeba', sessionToken: sessionToken);

  if (res.isOkay) {
    // list autocomplete prediction
    for (var p in res.predictions) {
      print('- ${p.description}');
    }

    final placeId = res.predictions.first.placeId;
    if (placeId == null) return;

    // get detail of the first result
    var details = await places.getDetailsByPlaceId(
      placeId,
      sessionToken: sessionToken,
    );

    print('\nDetails :');
    print(details.result.formattedAddress);
    print(details.result.formattedPhoneNumber);
    print(details.result.url);
  } else {
    print(res.errorMessage);
  }

  places.dispose();
}

