import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fridgify/screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridgify',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body:
      Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(

            image: DecorationImage(
            image: ExactAssetImage('assets/images/bg.jpg'),
            fit: BoxFit.fill,
        ),
        ),
            child: BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
        ),
        LoginForm()
        ]),
    );
  }
}
