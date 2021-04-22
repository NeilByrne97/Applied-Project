import 'dart:async';
import 'package:androidbluetoothserialapp/screens/home.dart';
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

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}*/

class _MainPage extends State<MainPage> {
  StreamSubscription<User> loginStateSubScription;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubScription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      }
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
              title: StreamBuilder<User>(
                  stream: authBloc.currentUser,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    print(snapshot.data.photoURL);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(snapshot.data.displayName,
                        //     style: TextStyle(fontSize: 35.0)),
                        // SizedBox(height: 100.0),
                        // CircleAvatar(
                        //   backgroundImage: NetworkImage(snapshot.data.photoURL
                        //       .replaceFirst('s96', 's400')),
                        //   radius: 60.0,
                        // ),
                        // SizedBox(
                        //   height: 100.0,
                        // ),
                        SignInButton(Buttons.Google,
                            text: 'Sign Out of Google',
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => authBloc.logout()))),
                        MaterialButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            child: Text("Sign out")),
                      ],
                    );
                  }),
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
            ListTile(
                title: RaisedButton(
                    child: const Text('Places'),
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => PlacesDetails())))),
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
