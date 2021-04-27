import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

import 'AuthBloc.dart';
import 'Login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  StreamSubscription<User> loginStateSubScription;
  String _email;
  String _password;
  String _firstName;
  String _lastName;
  String _avatar;

  String uid;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  final List<String> avatars = [
    'assets/Banana.png',
    'assets/Batman.png',
    'assets/Default.png',
    'assets/Spider.png',
    'assets/Tree.png'
  ];

  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    // loginStateSubScription = authBloc.currentUser.listen((fbUser) {
    //   if (fbUser != null) {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(
    //         builder: (context) => MainPage(),
    //       ),
    //     );
    //   }
    // });
    super.initState();
  }

  Future<void> _createUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      _addCred();
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    } catch (e) {
      print("Error: $e");
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }

  void _addCred() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    String docName = _lastName + " " + _firstName;
    try {
      await usersCollection
          .doc(uid)
          .collection('Credentials')
          .doc(docName)
          .set({
        'firstName': _firstName,
        'lastName': _lastName,
        'avatar': _avatar,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Contact Tracer",
                  style: TextStyle(
                    fontSize: 50.0,
                  ),
                ),
              ),
              FlutterLogo(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Sign Up Here",
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "First Name"),
                          validator: (_val) {
                            if (_val.isEmpty) {
                              return "Can't be empty";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            _firstName = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Last Name"),
                          validator: (_val) {
                            if (_val.isEmpty) {
                              return "Can't be empty";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            _lastName = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Email"),
                          validator: (_val) {
                            if (_val.isEmpty) {
                              return "Can't be empty";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            _email = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Password"),
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: "This Field Is Required."),
                            MinLengthValidator(6,
                                errorText: "Minimum 6 Characters Required.")
                          ]),
                          onChanged: (val) {
                            _password = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            //margin: const EdgeInsets.only(right: 10, left: 10, top: 200),
                            height: 60,
                            //width: 40,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: avatars.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      _avatar = avatars[index];
                                    },
                                    child: Image.asset(
                                        avatars[index].toString(),
                                        height: 60,
                                        width: 60),
                                  );
                                })),
                      ),
                      RaisedButton(
                        onPressed: _createUser,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          "Sign Up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SignInButton(Buttons.Google,
                  onPressed: () => authBloc.loginGoogle()),
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  // send to login screen
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text(
                  "Login Here",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
