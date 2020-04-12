import 'dart:convert';

import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/not_unique_exception.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String userApi = "${Repository.baseURL}users/";

  User user;

  Logger logger = Logger();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  static final UserService _userService = UserService._internal();

  factory UserService() {
    return _userService;
  }

  UserService._internal();

  Future<User> fetchUser() async {
    logger.i('UserService => FETCHING USER FROM URL: $userApi');

    var response = await http.get(userApi, headers: Repository.getHeaders());

    logger.i('UserService => FETCHING USER DATA: ${response.body}');

    if (response.statusCode == 200) {
      var user = jsonDecode(response.body);
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

    var response = await http.get('$userApi$fridgeId/', headers: Repository.getHeaders());

    logger.i(
        'UserService => FETCHING USERS FOR FRIDGE $fridgeId: ${response.body}');

    if (response.statusCode == 200) {
      var users = jsonDecode(response.body);
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

    var response = await http.patch(userApi,
        headers: Repository.getHeaders(),
        body: jsonEncode({parameter: attribute}),
        encoding: utf8);

    logger.i('UserService => PATCHING USER: ${response.statusCode}');

    if (response.statusCode == 200) {
      var us = jsonDecode(response.body);
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

  Future<void> checkUsernameEmail(String user, String mail) async {
    logger.i(
        'UserService => CHECKING IF $user and $mail ARE UNIQUE FROM URL: ${userApi}duplicate/');

    var response = await http.post("${userApi}duplicate/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": user,
          "mail": mail
        }),
        encoding: utf8);

    logger.i('UserService => CHECKING FOR DUPLICATE USER: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);

    if (response.statusCode == 200) {
      logger.i('UserService => EMAIL USER UNIQUE ${response.body}');

      return;
    }

    throw new NotUniqueException(user: res.containsKey('username'), mail: res.containsKey('email'));
  }
}
