import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fridgify/view/screens/login.view.dart';
import 'package:fridgify/view/screens/overview.view.dart';

import 'config.dart';
import 'controller/auth.controller.dart';
import 'controller/fridge.controller.dart';

Future main() async  {
    var cache = await DefaultCacheManager().getFileFromCache("auth.json");
    var token = cache.file.readAsStringSync();
    Config.logger.i("Starting app with token: $token");
    Auth auth;
    Fridge fridge;
    List<Widget> frames;
    if(token != null)
    {
        auth = Auth.withToken(token);
        fridge = Fridge(auth);
        frames = await fridge.fetchFridgesOverview();

        Config.logger.i("Fetching fridges! $frames");
    }
    runApp(MyApp(token, frames));
    }

class MyApp extends StatelessWidget {
  String token;
  List<Widget> frames;
  MyApp(this.token, this.frames);
  @override
  Widget build(BuildContext context) {
    if(this.token != null)
      return MaterialApp(
        title: 'Fridgify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Overview(title: 'Overview', token: token, frames: this.frames,),
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