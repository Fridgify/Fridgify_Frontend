import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fridgify/exceptions/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/auth.model.dart';
import 'package:path_provider/path_provider.dart';

import '../config.dart';

/// Function calls to the Models
/// Fetch token


class Auth {
  String user;
  String password;
  String apiToken;
  String clientToken;

  String email;
  String name;
  String surname;
  String date;

  DateTime death;

  AuthModel model = new AuthModel();


  Auth(String user, String password) {
    Config.logger.i("Basic Auth Const: user: $user, pass: $password");
    this.user = user;
    this.password = password;
  }

  Auth.withToken(String token) {
    Config.logger.i("Token Auth Const: Token: $token");
    this.clientToken = token;
  }

  Auth.withRegister(String user, String password, String email, String name,
                    String surname, String date)  {
    Config.logger.i("Register Auth Const: user: $user"
        ", password: $password, email: $email, name: $name, surname: $surname,"
        "date: $date");
    this.user = user;
    this.password = password;
    this.email = email;
    this.name = name;
    this.surname = surname;
    this.date = date;
  }

  Future setClientToken() async {
    try {
      this.clientToken =
      await model.fetchClientTokenLogin(this.user, this.password);
    } catch(e) {
      Config.logger.e(e);
    }
    await writeToCache(this.clientToken, "auth.json", new Duration(days: 14));
  }

  Future setClientTokenRegister() async {
    try {
      if(await model.fetchRegister(this.user, this.password, this.email,
                                            this.name, this.surname, this.date))
        this.clientToken = await model.fetchClientTokenLogin(this.user, this.password);
    } catch(e) {
      Config.logger.e(e);
    }
  }

  Future setApiToken() async {
    Config.logger.i("Setting API Token with Client Token: $clientToken");
    this.apiToken = await model.fetchAPIToken(this.clientToken);
  }

  Future<bool> validateToken() async {
    return await model.validateToken(this.clientToken) == "invalid token" ? false : true;
  }

  Future writeToCache(String token, String file, Duration d) async {
    Config.logger.i("Writing $token to Cache.. $file");
    final directory = await getApplicationDocumentsDirectory();
    var f = new File('${directory.path}/dummy.json');
    f.writeAsStringSync(token);
    DefaultCacheManager().putFile(file, f.readAsBytesSync(), maxAge: d);
    Config.logger.i("File in Cache ${DefaultCacheManager().getFileFromCache(file)}");
  }

  Future<bool> login() async {
    await setClientToken();
    await setApiToken();
    Config.logger.i("Logging in: ${this.clientToken} ${this.apiToken}");
    return await validateToken();
  }

  Future<bool> register() async {
    await setClientTokenRegister();
    await setApiToken();
    Config.logger.i("Registering: ${this.clientToken} ${this.apiToken}");
    return await validateToken();
  }


}