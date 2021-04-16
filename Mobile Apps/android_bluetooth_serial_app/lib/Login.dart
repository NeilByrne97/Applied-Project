import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';

import 'AuthBloc.dart';
import 'MainPage.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  StreamSubscription<User> loginStateSubScription;

  @override
  void initState(){
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubScription = authBloc.currentUser.listen((fbUser){
      if (fbUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose(){
    loginStateSubScription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SignInButton(Buttons.Google, onPressed: () => authBloc.loginGoogle()),
        ],
        )
      ));
  }
}
