import 'dart:async';
import 'package:androidbluetoothserialapp/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

import './SelectBondedDevicePage.dart';
import './ChatPage.dart';
import 'AuthBloc.dart';
import 'Login.dart';
import 'Places.dart';

class EmailMainPage extends StatefulWidget {
  @override
  _EmailMainPage createState() => new _EmailMainPage();
}

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}*/

class _EmailMainPage extends State<EmailMainPage> {
  StreamSubscription<User> loginStateSubScription;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  String firstName;
  String lastName;
  String fullName = "";
  String avatar = "assets/Default.png";

  getFullName(fullName) {
    this.fullName = fullName;
  }

  getAvatar(avatar) {
    this.avatar = avatar;
  }

  void getCollection() {
    _getUID();
    usersCollection
        .doc(uid)
        .collection('Credentials')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        print(documentSnapshot.data().toString());
        firstName = documentSnapshot['firstName'];
        lastName = documentSnapshot['lastName'];
        avatar = documentSnapshot['avatar'];

        fullName = firstName + " " + lastName;
        getFullName(fullName);

        getAvatar(avatar);
        //print("full name " + fullName);
        //print("YOOOO");
      });
    });
  }

  void _getUID() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    this.uid = uid;
    print("Current user is " + uid);
  }

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  bool _autoAcceptPairingRequests = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  String uid;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubScription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        print("FB user is ");
        print(fbUser);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      }
      var firstName = getCollection();
    });
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    loginStateSubScription.cancel();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(' Covid-19 Contact Tracing  '),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            ListTile(
              title: Text(fullName),
            ),
            CircleAvatar(
              child: Image.asset(avatar),
              radius: 60.0,
            ),
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            Divider(),
            ListTile(title: const Text('Bluetooth devices')),
            ListTile(
              title: RaisedButton(
                child: const Text('Connect and Send Contact Information'),
                onPressed: () async {
                  final BluetoothDevice selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );
                  if (selectedDevice != null) {
                    print('Connect -> selected ' + selectedDevice.address);
                    _startChat(context, selectedDevice);
                  } else {
                    print('Connect -> no device selected');
                  }
                },
              ),
            ),
            ListTile(title: RaisedButton(child: const Text('Placccccccces'))),
            Divider(),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
