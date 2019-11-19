import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Auth {
  String mail;
  String password;
  String staticToken;
  String fetchedToken;
  DateTime death;


  Auth(String mail, String password) {
    this.mail = mail;
    this.password = password;
  }


  String _fetchStaticToken() {
    var f = new File('auth');
    f.writeAsStringSync("dummyToken");
    DefaultCacheManager().putFile("auth.json", f.readAsBytesSync(), maxAge: new Duration(days: 30));
  }

  static String fetchToken(String staticToken) {
    // TODO:
    // Call to /login/ validate staticToken
    // Call to /token/ fetch new Token
    // Time it
    return null;
  }

  bool login() {
    return false;
    // TODO:
    // Call to /login/ endpoint returns static token body: email pass OR header auth: static token to validate
    // Call to /token/ endpoints with static token in header
    this.staticToken = _fetchStaticToken();
    this.staticToken = fetchToken(this.staticToken);
    if(this.staticToken != null && this.fetchedToken != null)
      return true;
    return false;
  }


  bool register() {
    return false;
    this.staticToken = _fetchStaticToken();
    this.staticToken = fetchToken(this.staticToken);
    if(this.staticToken != null && this.fetchedToken != null)
      return true;
    return false;
  }
}