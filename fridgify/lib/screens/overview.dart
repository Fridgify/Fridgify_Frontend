import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fridgify/auth/auth.dart';

class Overview extends StatefulWidget {
  Auth auth;

  Overview({Key key, this.title, this.token}) : super(key: key) {
    auth = new Auth.withToken(token);
  }
  final String token;
  final String title;

  @override
  _OverviewState createState() => _OverviewState(auth);
}

class _OverviewState extends State<Overview> {
  Auth auth;
  _OverviewState(Auth auth) {
    this.auth = auth;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: new Key('overview'),
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
              title: Text("Overview"),
            ),
            GestureDetector(
              onTap: () => this.auth.fetchToken(),
              child: Center(
                child: Text("Press me"),
              ),
            )
          ]),
    );
  }
}
