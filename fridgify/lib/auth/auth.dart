import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fridgify/config.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

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

  Auth.withToken(String token) {
    this.staticToken = token;
  }


  /// Fetch the static login token which is needed for the API token
  /// And Cache it
  Future<void> _fetchStaticToken() async {
    // Request the login Token
    var response = await post(Config.API + Config.LOGIN, headers: {"Content-Type": "application/json"}, body: jsonEncode({"username": this.mail, "password": this.password}), encoding: utf8);

    // Create temporary file to cache
    final directory = await getApplicationDocumentsDirectory();
    var f = new File('${directory.path}/dummy.json');
    f.writeAsStringSync(response.body);

    // Cache temporary file
    this.staticToken = jsonDecode(response.body)["token"];
    DefaultCacheManager().putFile("auth.json", f.readAsBytesSync(), maxAge: new Duration(days: 14));
  }

  /// Validate the Login Token
  /// And fetch the API token with it for further requests
  Future<void> fetchToken() async {
    var response = await get(Config.API + Config.TOKEN, headers: {"Authorization": staticToken});
    this.fetchedToken = jsonDecode(response.body)["token"];
  }

  Future<bool> validateToken() async {
    var validate = await post(Config.API + Config.LOGIN, headers: {"Authorization": staticToken});
    return validate.body.toLowerCase() == "invalid token" ? false : true;
  }

  Future<bool> login() async {
    await _fetchStaticToken();
    await fetchToken();
    return await validateToken();
  }


  bool register() {
    return false;
    /*
    this.staticToken = _fetchStaticToken();
    this.staticToken = fetchToken(this.staticToken);
    if(this.staticToken != null && this.fetchedToken != null)
      return true;
    return false;*/
  }
}