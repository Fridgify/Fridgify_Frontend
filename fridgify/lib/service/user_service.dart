import 'dart:convert';

import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_qr_exception.dart';
import 'package:fridgify/exception/failed_to_patch_user_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgify/utils/permission_helper.dart';

class UserService {
  static const String userApi = "${Repository.baseURL}users/";
  static const String userManagementApi = "${Repository.baseURL}fridge/management/";

  Client client;

  User user;

  Logger logger = Logger();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  static final UserService _userService = UserService._internal();

  factory UserService([Client client]) {
    if(client != null) {
      _userService.client = client;
    } else {
      _userService.client = Client();
    }
    return _userService;
  }

  UserService._internal();

  Future<User> fetchUser() async {
    logger.i('UserService => FETCHING USER FROM URL: $userApi');

    var response = await client.get(userApi, headers: Repository.getHeaders());

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

  User get() {
    return this.user;
  }

  Future<User> update(User user, String parameter, dynamic attribute) async {
    logger.i(
        'UserService => UPDATING $parameter with $attribute FROM URL: $userApi');

    var response = await client.patch(userApi,
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

  Future<Map<String, bool>> checkUsernameEmail(String user, String mail) async {

    logger.i(
        'UserService => CHECKING IF $user and $mail ARE UNIQUE FROM URL: ${userApi}duplicate/');

    var response = await client.post("${userApi}duplicate/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": user,
          "email": mail
        }),
        encoding: utf8);

    logger.i('UserService => CHECKING FOR DUPLICATE USER: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);

    if (response.statusCode == 200) {
      logger.i('UserService => EMAIL USER UNIQUE ${response.body}');
      return {"user": false, "mail": false};
    }

    return {"user": res.containsKey('username'), "mail": res.containsKey('email')};

  }

  Future<String> patchUser(Fridge f, User u, int role) async {

    var userUrl = "$userManagementApi${f.fridgeId}/users/${u.userId}/";

    logger.i("UserService => PATCHING USER ${u.username} FOR FRIDGE ${f.fridgeId} NEW ROLE $role URL $userUrl");

    var response = await client.patch(userUrl, headers: Repository.getHeaders(), body: jsonEncode({
      "role": role
    }),
    encoding: utf8);

    logger.i('UserService => PATCHED USER ${response.body}');

    if(response.statusCode == 200) {
      return jsonDecode(response.body)['role'];
    }

    throw FailedToPatchUserException();

  }

  Future<bool> kickUser(Fridge f, User u) async {

    var userUrl = "$userManagementApi${f.fridgeId}/users/${u.userId}/";

    logger.i("UserService => REMOVING USER ${u.username} FOR FRIDGE ${f.fridgeId} URL $userUrl");

    var response = await client.delete(userUrl, headers: Repository.getHeaders(),);

    logger.i('UserService => REMOVED USER ${response.body}');

    if(response.statusCode == 200) {
      return true;
    }

    throw FailedToPatchUserException();

  }

  Future<String> fetchDeepLink(Fridge f) async {
    var fridgeUrl = "$userManagementApi/${f.fridgeId}/qr-code";

    logger.i("UserService => FETCHIGN QR FROM $fridgeUrl");

    var response = await client.get(fridgeUrl, headers: Repository.getHeaders());


    logger.i("UserService => RESPONSE FROM ${response.body}");

    if(response.statusCode == 201) {
      return jsonDecode(response.body)["dynamic_link"];
    }

    throw FailedToFetchQrException();

  }
}
