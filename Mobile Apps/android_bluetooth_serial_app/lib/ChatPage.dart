import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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

  getFirstName(firstName){
    this.firstName = firstName;
  }

  getLastName(lastName){
    this.lastName = lastName;
  }

  getPhoneNumber(phoneNumber){
    this.phoneNumber = phoneNumber;
  }

  getEmail(email){
    this.email = email;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  void _create() async {
    String docName =lastName + " " + firstName;

    try {
      await firestore.collection('Contacts').doc(docName).set({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
      });
    } catch (e) {
      print(e);
    }
  }

  void _read() async {
    String docName ="Neil Byrne";
    DocumentSnapshot documentSnapshot;
    try {
      documentSnapshot = await firestore.collection('Contacts').doc(docName).get();
      print(documentSnapshot.data);
    } catch (e) {
      print(e);
    }
  }

  void _update() async {
    try {
      firestore.collection('users').doc('testUser').update({
        'firstName': 'Alan',
      });
    } catch (e) {
      print(e);
    }
  }

  void _delete() async {
    try {
      firestore.collection('users').doc('testUser').delete();
    } catch (e) {
      print(e);
    }
  }


  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

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
              : Text('Chat log with ' + widget.server.name))),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    controller: listScrollController,
                    children: list),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: TextFormField(         // FirstName
                      decoration: InputDecoration(
                          labelText: "First Name",
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue,
                                  width: 2.0
                              )
                          )
                      ),
                      onChanged: (String firstName){
                        getFirstName(firstName);
                      },
                    ),
                  ),
                ],
              ),
              Flexible(
                flex: 2,
                child: TextFormField(         // LastName
                  decoration: InputDecoration(
                      labelText: "Last Name",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue,
                              width: 2.0
                          )
                      )
                  ),
                  onChanged: (String lastName){
                    getLastName(lastName);
                  },
                ),
              ),
              Flexible(
                flex: 2,
                child: TextFormField(         // PhoneNumber
                  decoration: InputDecoration(
                      labelText: "Phone Number",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue,
                              width: 2.0
                          )
                      )
                  ),
                  onChanged: (String phoneNumber){
                    getPhoneNumber(phoneNumber);
                  },
                ),
              ),
              Flexible(
                flex: 2,
                child: TextFormField(         // Email
                  decoration: InputDecoration(
                      labelText: "Email",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue,
                              width: 2.0
                          )
                      )
                  ),
                  onChanged: (String email){
                    getEmail(email);
                  },
                ),
              ),
              Flexible(
                flex: 2,
                child: ListView.builder(
                    itemBuilder: (context, index)){

                  },

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
                ),*/  // Type message
              Container(
                margin: const EdgeInsets.all(8.0),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isConnected
                        ? () => _sendMessage(firstName + "-" + lastName + "-" + phoneNumber + "-" + email)
                        : null),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _create,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: getIt,
                ),
              ),
            ],
          )
    ),
    );
  }

  void getIt(){
    firestore.collection("Contacts").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
        print("break");
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

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
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
        connection.output.add(utf8.encode(text + "\r\n"));
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
}