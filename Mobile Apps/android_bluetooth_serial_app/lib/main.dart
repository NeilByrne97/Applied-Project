import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './MainPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.cyan
    );
    return MaterialApp(home: MainPage());
  }
}
