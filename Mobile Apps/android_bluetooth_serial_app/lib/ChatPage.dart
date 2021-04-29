import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:androidbluetoothserialapp/Places.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_maps_webservice/places.dart';

import 'MainPage.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  String firstName, lastName, phoneNumber, email;

  static final clientID = 0;
  BluetoothConnection connection;

  getFirstName(firstName) {
    this.firstName = firstName;
  }

  getLastName(lastName) {
    this.lastName = lastName;
  }

  getPhoneNumber(phoneNumber) {
    this.phoneNumber = phoneNumber;
  }

  getEmail(email) {
    this.email = email;
  }

  var firstNameField = TextEditingController();
  var lastNameField = TextEditingController();
  var phoneNumberField = TextEditingController();
  var emailField = TextEditingController();

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  String uid;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');

  CollectionReference placesCollection =
  FirebaseFirestore.instance.collection('Places');

  Future fetchDetails() async {
    usersCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
      });
    });
  }

  void _addPlaceID(String placeID) async {
    final places =
    new GoogleMapsPlaces(apiKey: "AIzaSyAz6TJpPOpuhahblOebTaiCmtXHcipwxjc");
    //String place = "ChIJ_aKF2fqWW0gRDLLSSGNL_hc";

    PlacesDetailsResponse response = await places.getDetailsByPlaceId(placeID);

    String name = response.result.name;
    String formattedAddress = response.result.formattedAddress;
    String formattedPhoneNumber = response.result.formattedPhoneNumber;
    String website = response.result.website;

    try {
      await usersCollection.doc(uid).collection('Places').doc(name).set({
        'name': name,
        'formattedAddress': formattedAddress,
        'formattedPhoneNumber': formattedPhoneNumber,
        'website' : website,
        'placeID' : placeID,
      });
      getCollection(); // Update the list displayed
    } catch (e) {
      print(e);
    }
  }

  void _getUID() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    this.uid = uid;
  }

  void _create() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    String docName = lastName + " " + firstName;
    try {
      await usersCollection.doc(uid).collection('Contacts').doc(docName).set({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
      });
      getCollection(); // Update the list displayed
    } catch (e) {
      print(e);
    }
  }

  void _update() async {
    String docName = lastNameField.text + " " + firstNameField.text;
    try {
      usersCollection.doc(uid).collection('Contacts').doc(docName).update({
        'firstName': firstNameField.text,
        'lastName': lastNameField.text,
        'phoneNumber': phoneNumberField.text,
        'email': emailField.text,
      });
      print("Updating " + docName);
      getCollection(); // Update the list displayed
    } catch (e) {
      print(e);
    }
  }

  void _delete() async {
    String docName = lastNameField.text + " " + firstNameField.text;
    try {
      usersCollection.doc(uid).collection('Contacts').doc(docName).delete();
      firstNameField.text = "";
      lastNameField.text = "";
      phoneNumberField.text = "";
      emailField.text = "";
      print("Deleting " + docName);
      getCollection(); // Update the list displayed
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting chat to ' + widget.server.name + '...')
              : isConnected
                  ? Text('Connected with ' + widget.server.name)
                  : Text('Chat log with ' + widget.server.name)),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MainPage()));
            },
            child: Icon(
              Icons.arrow_back, // add custom icons also
            ),
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    _getPlaceID();
                  },
                  child: Icon(
                    Icons.map_rounded, // add custom icons also
                  ),
                )),
          ]),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Flexible(
            // Display sent messages
            child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: list),
          ),

          Row(
            children: <Widget>[
              Flexible(
                flex: 6,
                child: TextFormField(
                  // FirstName
                  controller: firstNameField,
                  decoration: InputDecoration(
                      labelText: "  First Name",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0))),
                  onChanged: (String firstName) {
                    getFirstName(firstName);
                  },
                ),
              ),
            ],
          ),
          Flexible(
            flex: 6,
            child: TextFormField(
              // LastName
              controller: lastNameField,
              decoration: InputDecoration(
                  labelText: "  Last Name",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0))),
              onChanged: (String lastName) {
                getLastName(lastName);
              },
            ),
          ),
          Flexible(
            flex: 6,
            child: TextFormField(
              // PhoneNumber
              controller: phoneNumberField,
              decoration: InputDecoration(
                  labelText: "  Phone Number",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0))),
              onChanged: (String phoneNumber) {
                getPhoneNumber(phoneNumber);
              },
            ),
          ),
          Flexible(
            flex: 6,
            child: TextFormField(
              // Email
              controller: emailField,
              decoration: InputDecoration(
                  labelText: "  Email",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0))),
              onChanged: (String email) {
                getEmail(email);
              },
            ),
          ),
          /*  Flexible(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                            ? 'Type your message...'
                            : 'Chat got disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ),
                  ),
                ),*/ // Type message
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(
                icon: const Icon(Icons.send),
                color: Colors.blue,
                iconSize: 50,
                onPressed: isConnected
                    ? () => _sendMessage(firstName +
                        "-" +
                        lastName +
                        "-" +
                        phoneNumber +
                        "-" +
                        email)
                    : null),
            IconButton(
              color: Colors.blue,
              iconSize: 50,
              icon: const Icon(Icons.save),
              onPressed: _createAlert,
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(
              color: Colors.blue,
              iconSize: 50,
              icon: const Icon(Icons.update),
              onPressed: _updateAlert,
            ),
            IconButton(
              color: Colors.blue,
              iconSize: 50,
              icon: const Icon(Icons.delete),
              onPressed: _deleteAlert,
            ),
          ]),
          Flexible(
              flex: 24,
              child: ListView.builder(
                controller: listScrollController,
                padding: const EdgeInsets.all(12.0),
                itemBuilder: (context, index) {
                  _getUID();
                  return StreamBuilder<QuerySnapshot>(
                    stream: usersCollection.doc(uid).collection('Contacts').snapshots(),
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
                                  title: new Text(document['firstName'] +
                                      " " +
                                      document['lastName']),
                                  subtitle: new Text("Phone Number: " +
                                      document['phoneNumber'] +
                                      "\nEmail: " +
                                      document['email']),
                                  onTap: () {
                                    firstNameField.text = document['firstName'];
                                    lastNameField.text = document['lastName'];
                                    phoneNumberField.text =
                                        document['phoneNumber'];
                                    emailField.text = document['email'];
                                    getFirstName(document['firstName']);
                                    getLastName(document['lastName']);
                                    getPhoneNumber(document['phoneNumber']);
                                    getEmail(document['email']);
                                    print(document['firstName'] +
                                        " " +
                                        document['lastName']);
                                  });
                            }).toList(),
                          );
                      }
                    },
                  );
                },
              )),
        ],
      )),
    );
  }

  void getCollection() {
    usersCollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        print(documentSnapshot.data().toString());
      });
    });
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    String espPlaceID = "";
    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    espPlaceID += dataString;
    print("Message is " + espPlaceID);
    _addPlaceID(espPlaceID);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  Future<void> _createAlert() async {
    _create();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('New Contact Added!'),
                Text(firstNameField.text + " " + lastNameField.text),
                Text('Phone Number: ' + phoneNumberField.text),
                Text('Email: ' + emailField.text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This will permanently delete ' +
                    firstNameField.text +
                    " " +
                    lastNameField.text),
                Text('Are you sure?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
                _delete();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This will permanently update ' +
                    firstNameField.text +
                    " " +
                    lastNameField.text),
                Text('Phone Number: ' + phoneNumberField.text),
                Text('Email: ' + emailField.text),
                Text('Are you sure?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Update'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
                _update();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getPlaceID() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to receive the Contact information?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _sendMessage("placeID");
                Navigator.of(context).pop(); // Close dialog box
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog box
              },
            ),
          ],
        );
      },
    );
  }
}
