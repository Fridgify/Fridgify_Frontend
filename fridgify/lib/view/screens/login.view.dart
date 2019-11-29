import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/view/widgets/forms/login_form_widget.dart';
// Create a Form widget.

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(

                image: DecorationImage(
                  image: ExactAssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
            Container(
              color: Color.fromARGB(100, 0, 0, 0),
            ),
            AppBar (
              backgroundColor: Colors.transparent,
              title: Text("Sign-In"),
            ),
            LoginForm(),
          ]),
    );
  }
}
