import 'dart:convert';
import 'dart:core';

import 'package:fridgify/exceptions/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exceptions/failed_to_fetch_client_token.dart';
import 'package:http/http.dart';


import 'package:fridgify/config.dart';

/// Auth Model contains all the request calls to the /auth/* Endpoint
/// Login call
/// Register call
/// Fetch token call

class AuthModel {
  Future<String> fetchClientTokenLogin(String user, String password) async {
    var response = await post(Config.API + Config.LOGIN,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": user, "password": password}),
        encoding: utf8);
    Config.logger.i('Fetching Client token: ${response.body}');
    if(response.statusCode == 200)
      return jsonDecode(response.body)["token"];
    throw new FailedToFetchClientTokenException();
  }

  Future<bool> fetchRegister(String user, String password, String email, String name, String surname, String date) async {
    var response = await post(Config.API + Config.REGISTER,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": user, "password": password,
          "name": name, "surname": surname, "email": email, "birthdate": date}), encoding: utf8);
    Config.logger.i('Fetching Client token: ${response.body}');
    if(response.statusCode == 201)
      return true;
    throw new FailedToFetchClientTokenException();
  }

  Future<String> fetchAPIToken(String clientToken) async {
    var response = await get(Config.API + Config.TOKEN, headers: {"Authorization": clientToken});
    Config.logger.i('Fetching API token: ${response.body}');
    if(response.statusCode == 200)
      return jsonDecode(response.body)["token"];
    throw new FailedToFetchApiTokenException();
  }

  Future<String> validateToken(String clientToken) async {
    var response = await post(Config.API + Config.LOGIN, headers: {"Authorization": clientToken});
    Config.logger.i('Validating token: ${response.body}');
    return response.body;
  }


}