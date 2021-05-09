import 'package:androidbluetoothserialapp/AuthBloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Login.dart';
import 'Places.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        title: 'Contact Tracer',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Login(),
      ),
    );
  }
}
