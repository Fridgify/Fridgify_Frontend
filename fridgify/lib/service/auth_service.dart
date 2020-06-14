import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/firebase_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/logger.dart';

/// This Authentication Service handles login, registration and token fetching
/// It works with the cache "Repository.sharedPreferences" and keeps it all time updated
class AuthenticationService {
  static final String authAPI = "${Repository.baseURL}auth/";

  User user;

  Logger _logger = Logger('AuthenticationService');

  Dio dio;

  //Repository.sharedPreferences Repository.sharedPreferences = Repository.Repository.sharedPreferences;

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
    this.dio = Repository.getDio();
    _logger.i("NEW USER: ${user.toString()}");
  }

  /// Constructor for login use case
  AuthenticationService.login(String username, String password) {
    user = User.loginUser(username: username, password: password);
    this.dio = Repository.getDio();
    _logger.i("LOGIN: ${user.toString()}");
  }

  AuthenticationService([Dio dio]) {
    this.dio = Repository.getDio(dio);
  }

  /// Register call
  Future<String> register() async {
    var response = await dio.post("$authAPI/register/",
        data: jsonEncode({
          "username": user.username,
          "password": user.password,
          "name": user.name,
          "surname": user.surname,
          "email": user.email,
          "birth_date": user.birthDate
        }),
        options: Options(headers: {"Content-Type": "application/json"})
    );

    _logger.i('REGISTER: ${response.data}');

    if (response.statusCode == 201) {
      _logger.i('REGISTER SUCCESSFUL ${response.statusCode}');

      return await login();
    }

    throw FailedToFetchClientTokenException();
  }

  /// Login call to fetch client token
  Future<String> login() async {
    _logger.i('LOGGING');

    var response = await dio.post("$authAPI/login/",
        data: jsonEncode({"username": user.username, "password": user.password}),
        options: Options(headers: {"Content-Type": "application/json"})
    );

    _logger.i('LOGGING IN: ${response.data}');

    if (response.statusCode == 200) {
      var token = response.data["token"];

      _logger.i('FETCHED CLIENTTOKEN $token');

      await Repository.sharedPreferences.setString("clientToken", token);
      _logger.i('WROTE TO CACHE');

      return token;
    }

    String err = response.data["detail"];
    throw FailedToFetchClientTokenException.withErr(err);
  }

  /// Logout by cleaning cache
  Future<bool> logout() async {
    bool cacheClear =
        await Repository.sharedPreferences.remove("clientToken") && await Repository.sharedPreferences.remove("apiToken");

    _logger.i(
        "LOGGING OUT BY CLEARING CACHE FROM TOKENS: $cacheClear");


    return cacheClear;
  }

  // Fetch API token
  Future<String> fetchApiToken() async {
    final clientToken = Repository.sharedPreferences.getString("clientToken") ?? null;

    if (clientToken == null) {
      _logger.e("NO CLIENT TOKEN FOUND IN CACHE");
      throw FailedToFetchClientTokenException();
    }

    var response =
    await dio.get("$authAPI/token/", options: Options(
      headers: {"Authorization": clientToken}));


    _logger.i('FETCHING API TOKEN ${response.data}');

    if (response.statusCode == 201) {
      var token = response.data["token"];
      var timer = response.data["validation_time"];

      _logger.i("FETCHED TOKEN: $token");

      await Repository.sharedPreferences.setString("apiToken", token);
      _logger.i(
          "WROTE TO CACHE - STARTING TIMER OF $timer SECONDS", upload: true);

      /*
        Starting timer with the Token live time and fetch a new token if timer
        expires -> Maybe outsource to extra function?
       */
      Timer(Duration(seconds: 60/*timer*/), () async {

        _logger.i("API TOKEN DIED FETCH NEW");
        if (await Repository.sharedPreferences.remove("apiToken")) {
          await fetchApiToken();
        }
      });

      return token;
    }
    throw FailedToFetchApiTokenException();
  }

  Future<bool> validateToken() async {

    final clientToken = Repository.sharedPreferences.getString("clientToken") ?? null;

    if (clientToken == null) {
      _logger.e("NO CLIENT TOKEN FOUND IN CACHE");
      throw FailedToFetchClientTokenException();
    }

    var response = await dio.post("$authAPI/login/", options: Options(
        headers: {"Authorization": clientToken}));

    _logger.i('VALIDATING TOKEN: ${response.data}');

    if(response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> initiateRepositories() async {
    FirebaseService firebaseService = FirebaseService();
    StoreRepository storeRepository = StoreRepository();
    ItemRepository itemRepository = ItemRepository();
    FridgeRepository fridgeRepository = FridgeRepository();
    UserService userService = UserService();

    try {
      _logger.i('FETCHING ALL REPOSITORIES', upload: true);
      firebaseService.initState();
      await Future.wait(
          [
            fridgeRepository.fetchAll(),
            storeRepository.fetchAll(),
            itemRepository.fetchAll(),
            userService.fetchUser(),
          ]
      );

    }
    catch(exception) {
      _logger.e('FAILED TO FETCH REPOSITORY', exception: exception);
      return false;
    }
    return true;
  }
}
