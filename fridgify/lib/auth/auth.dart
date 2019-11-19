import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Auth {
  String mail;
  String password;
  String static_token;
  String fetched_token;


  Auth() ;

  Auth.staticToken(String sToken) {
    this.static_token = sToken;
  }


  String _fetchStaticToken() {
    var f = new File('auth');
    f.writeAsStringSync("dummyToken");
    DefaultCacheManager().putFile("auth.json", f.readAsBytesSync(), maxAge: new Duration(days: 30));
  }

  static String fetchToken(String staticToken) {
    return null;
  }

  bool login() {
    this.static_token = _fetchStaticToken();
    this.fetched_token = fetchToken(this.static_token);
    if(this.static_token != null && this.fetched_token != null)
      return true;
    return false;

  }
}