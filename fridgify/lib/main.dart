import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fridgify/view/screens/login.view.dart';
import 'package:fridgify/view/screens/overview.view.dart';

Future main() async => runApp(MyApp(await DefaultCacheManager().getFileFromCache("auth.json") ));

class MyApp extends StatelessWidget {
  var cache;
  MyApp(var cache) {
    this.cache = cache;
  }
  @override
  Widget build(BuildContext context) {
    if(this.cache != null)
      return MaterialApp(
        title: 'Fridgify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Overview(title: 'Overview', token: jsonDecode((cache as FileInfo).file.readAsStringSync())['token']),
      );
    else
      return MaterialApp(
        title: 'Fridgify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Login(title: 'Login'),
      );
  }
}


