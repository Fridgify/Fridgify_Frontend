import 'dart:async';
import 'dart:convert';

import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/user.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart';

/// This Authentication Service handles login, registration and token fetching
/// It works with the cache "SharedPreferences" and keeps it all time updated
class AuthenticationService {
  static const String authAPI = "${Repository.baseURL}auth/";

  User user;

  Logger logger = Logger();

  final prefs = Repository.sharedPreferences;

  /// Constructor for the registration use case -> needs all data for user model
  AuthenticationService.register(
    String username,
    String password,
    String name,
    String surname,
    String email,
    String birthDate,
  ) {
    user = User.newUser(
        username: username,
        password: password,
        name: name,
        surname: surname,
        email: email,
        birthDate: birthDate);
    logger.i("AuthService => NEW USER: ${user.toString()}");
  }

  /// Constructor for login use case
  AuthenticationService.login(String username, String password) {
    user = User.loginUser(username: username, password: password);
    logger.i("AuthService => LOGIN: ${user.toString()}");
  }

  /// Register call
  Future<String> register() async {
    var response = await post("$authAPI/register/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": user.username,
          "password": user.password,
          "name": user.name,
          "surname": user.surname,
          "email": user.email,
          "birth_date": user.birthDate
        }),
        encoding: utf8);

    logger.i('AuthService => REGISTER: ${response.body}');

    if (response.statusCode == 201) {
      logger.i('AuthService => REGISTER SUCCESSFUL ${response.statusCode}');

      return await login();
    }

    throw FailedToFetchClientTokenException();
  }

  /// Login call to fetch client token
  Future<String> login() async {
    var response = await post("$authAPI/login/",
        headers: {"Content-Type": "application/json"},
        body:
            jsonEncode({"username": user.username, "password": user.password}),
        encoding: utf8);

    logger.i('AuthService => LOGGING IN: ${response.body}');

    if (response.statusCode == 200) {
      var token = jsonDecode(response.body)["token"];

      logger.i('AuthService => FETCHED CLIENTTOKEN $token');

      await prefs.setString("clientToken", token);
      logger.i('AuthService => WROTE TO CACHE');

      return token;
    }

    throw FailedToFetchClientTokenException();
  }

  /// Logout by cleaning cache
  Future<bool> logout() async {
    bool cacheClear =
        await prefs.remove("clientToken") && await prefs.remove("apiToken");

    logger.i(
        "AuthService => LOGGING OUT BY CLEARING CACHE FROM TOKENS: $cacheClear");

    return cacheClear;
  }

  // Fetch API token
  Future<String> fetchApiToken() async {
    final clientToken = prefs.getString("clientToken") ?? null;

    if (clientToken == null) {
      logger.e("AuthService => NO CLIENT TOKEN FOUND IN CACHE");
      throw FailedToFetchClientTokenException();
    }

    var response =
        await get("$authAPI/token/", headers: {"Authorization": clientToken});

    logger.i('AuthService => FETCHING API TOKEN ${response.body}');

    if (response.statusCode == 201) {
      var token = jsonDecode(response.body)["token"];
      var timer = jsonDecode(response.body)["validation_time"];

      logger.i("AuthService => FETCHED TOKEN: $token");

      await prefs.setString("apiToken", token);
      logger.i(
          "AuthService => WROTE TO CACHE - STARTING TIMER OF $timer SECONDS");

      /*
        Starting timer with the Token live time and fetch a new token if timer
        expires -> Maybe outsource to extra function?
       */
      Timer(Duration(seconds: timer), () async {
        logger.i("AuthService => API TOKEN DIED FETCH NEW");
        if (await prefs.remove("apiToken")) {
          await fetchApiToken();
        }
      });

      return token;
    }
    throw FailedToFetchApiTokenException();
  }

  Future<bool> validateToken() async {
    final clientToken = prefs.getString("clientToken") ?? null;

    if (clientToken == null) {
      logger.e("AuthService => NO CLIENT TOKEN FOUND IN CACHE");
      throw FailedToFetchClientTokenException();
    }

    var response =
        await post("$authAPI/login/", headers: {"Authorization": clientToken});
    logger.i('Validating token: ${response.body}');
    return response.body == "invalid token" ? false : true;
  }
}
