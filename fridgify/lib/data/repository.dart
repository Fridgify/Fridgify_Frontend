import 'package:dio/dio.dart';
import 'package:fridgify/cache/cache_interceptor.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Repository<Item, Key> {
  static final baseURL = "https://${GlobalConfiguration().get('host')}/";
  static SharedPreferences sharedPreferences;
  static bool isTest = false;


  static Logger _logger = Logger('Repository');

  static Dio getDio([Dio mockDio]) {
    if (isTest && mockDio == null) {
      return null;
    }
    if (mockDio != null) {
      return mockDio;
    } else {
      Dio dio = new Dio();
      dio.interceptors.add(CacheInterceptor());
      return dio;
    }
  }

  static dynamic getToken() {
    var token = sharedPreferences.get("apiToken") ?? null;
    if (token == null) {
      _logger.e("NO API TOKEN FOUND IN CACHE");
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
