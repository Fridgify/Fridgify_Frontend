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
        primarySwatch: Colors.blue,
      ),
      home: Login(title: 'Login'),
    );
  }
}


