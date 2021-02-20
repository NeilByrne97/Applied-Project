import 'package:flutter/material.dart';

import './MainPage.dart';

void main() => runApp(new Application(

));

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
