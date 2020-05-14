import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/cache/http_client_interceptor.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/not_unique_exception.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String userApi = "${Repository.baseURL}users/";

  Dio dio;

  User user;

  Logger logger = Logger();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  static final UserService _userService = UserService._internal();

  factory UserService([Client client]) {
    _userService.dio = Repository.getDio();
    return _userService;
  }

  UserService._internal();

  Future<User> fetchUser() async {
    logger.i('UserService => FETCHING USER FROM URL: $userApi');

    var response = await dio.get(userApi, options: Options(
      headers: Repository.getHeaders())
    );

    logger.i('UserService => FETCHING USER DATA: ${response.data}');

    if (response.statusCode == 200) {
      var user = response.data;
      User u = User.newUser(
          username: user['username'],
          password: user['password'],
          name: user['name'],
          surname: user['surname'],
          email: user['email'],
          birthDate: user['birth_date']);

      this.user = u;

      logger.i('UserService => $user');

      return this.user;
    }
    throw new FailedToFetchContentException();
  }

  Future<List<User>> getUsersForFridge(int fridgeId) async {
    List<User> usersList = List();

    logger.i('UserService => FETCHING USERS FROM URL: $userApi$fridgeId/');

    var response = await dio.get('$userApi$fridgeId/', options: Options(
        headers: Repository.getHeaders())
    );

    logger.i(
        'UserService => FETCHING USERS FOR FRIDGE $fridgeId: ${response.data}');

    if (response.statusCode == 200) {
      var users = response.data;
      for (var user in users) {
        User u = User.noPassword(
            username: user['username'],
            name: user['name'],
            surname: user['surname'],
            email: user['email'],
            birthDate: user['birth_date']);
        logger.i('UserService => FOUND USER $u');

        usersList.add(u);
      }

      logger.i('UserService => ${usersList.length}');
      return usersList;
    }
    throw new FailedToFetchContentException();
  }

  User get() {
    return this.user;
  }

  Future<User> update(User user, String parameter, dynamic attribute) async {
    logger.i(
        'UserService => UPDATING $parameter with $attribute FROM URL: $userApi');

    var response = await dio.patch(userApi,
        data: jsonEncode({parameter: attribute}),
        options: Options(
          headers: Repository.getHeaders())
    );

    logger.i('UserService => PATCHING USER: ${response.statusCode}');

    if (response.statusCode == 200) {
      var us = response.data;
      logger.i('UserService => UPDATED SUCCESSFUL $user');

      User u = User.newUser(
          username: us['username'],
          password: user.password,
          name: us['name'],
          surname: us['surname'],
          email: us['email'],
          birthDate: us['birth_date']);

      this.user = u;
      return u;
    }
    throw new FailedToFetchContentException();
  }

  Future<Map<String, bool>> checkUsernameEmail(String user, String mail) async {

    logger.i(
        'UserService => CHECKING IF $user and $mail ARE UNIQUE FROM URL: ${userApi}duplicate/');

    var response = await dio.post("${userApi}duplicate/",
        data: jsonEncode({
          "username": user,
          "email": mail
        }),
        options: Options(
            headers: {"Content-Type": "application/json"})
    );

    logger.i('UserService => CHECKING FOR DUPLICATE USER: ${response.data}');
    Map<String, dynamic> res = response.data;

    if (response.statusCode == 200) {
      logger.i('UserService => EMAIL USER UNIQUE ${response.data}');
      return {"user": false, "mail": false};
    }

    return {"user": res.containsKey('username'), "mail": res.containsKey('email')};

  }
}
