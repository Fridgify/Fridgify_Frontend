import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/auth.controller.dart';
import 'package:fridgify/controller/content.controller.dart';
// Create a Form widget.

class ContentView extends StatefulWidget {

  Auth auth;
  int id;
  List<Widget> content;
  ContentView(this.auth, this.id, this.content);

  @override
  _ContentViewState createState() => _ContentViewState(this.auth, this.id, this.content);
}

class _ContentViewState extends State<ContentView> {

  Auth auth;
  int id;
  List<Widget> content;


  _ContentViewState(this.auth, this.id, this.content);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: new Key("content"),
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
              title: Text("Content"),
            ),
            CustomScrollView(
              shrinkWrap: true,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      this.content
                    ),
                  ),
                ),
              ],
            )
          ]),
    );
  }
}
