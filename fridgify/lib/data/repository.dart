import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fridgify/cache/http_client_interceptor.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';


abstract class Repository<Item, Key> {
  static const baseURL = "https://fridgapi-dev.donkz.dev/";
  static SharedPreferences sharedPreferences;
  static Logger logger = Logger();

  static Dio getDio([Dio client]) {
    Dio dio = new Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (Response response) async {
        return response;
      },
      onError: (DioError e) async {
        if(e.response != null) {
          return e.response;
        } else {
          throw e;
        }
      }
    ));
    return dio;
  }

  static dynamic getToken() {
    var token = sharedPreferences.get("apiToken") ?? null;
    if (token == null) {
      logger.e("FridgeRepository => NO API TOKEN FOUND IN CACHE");
      throw FailedToFetchApiTokenException();
    }
    return token;
  }

  static Map<String, String> getHeaders() {
    var token = getToken();

    return {"Content-Type": "application/json", "Authorization": token};
  }

  Future<Map<Key, Item>> fetchAll() async {
    throw Exception("Not Implemented");
  }

  Item get(Key id) {
    throw Exception("Not Implemented");
  }

  Map<Key, Item> getAll() {
    throw Exception("Not Implemented");
  }

  Future<Key> add(Item item) async {
    throw Exception("Not Implemented");
  }

  Future<bool> delete(Key id) async {
    throw Exception("Not Implemented");
  }
}
