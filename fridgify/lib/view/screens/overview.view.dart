import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fridgify/config.dart';
import 'package:fridgify/controller/auth.controller.dart';
import 'package:fridgify/controller/fridge.controller.dart';
import 'package:fridgify/utils/fridges.dart';
import 'package:fridgify/view/widgets/fridge_frame.dart';

class Overview extends StatefulWidget {
  Auth auth;

  Overview({Key key, this.title, this.token}) : super(key: key) {
    Config.logger.i("Overview opened Client-Token: $token");
    auth = new Auth.withToken(token);
    Config.logger.i("Created Auth in Overview with Cached Token: ${auth.clientToken}");
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
            Container(
            padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
            child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(4.0),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                children: <FridgeFrame>[

                  FridgeFrame(new Fridges(1, "Hi", "Dummy", "Dummy")),
                ].map((FridgeFrame f) {
                  return GridTile(
                      child: f);
                }).toList()),
            ),
            GestureDetector(
              onTap: () {
                Fridge fridge = new Fridge(this.auth);
                fridge.fetchFridgesOverview();
              },
            )
          ]),
    );
  }
}
