import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Repository<Item> {
  static const baseURL = "https://fridgapi-dev.donkz.dev/";
  static SharedPreferences sharedPreferences;
  static Logger logger = Logger();

  static dynamic getToken() {
    var token = sharedPreferences.get("apiToken") ?? null;
    if (token == null) {
      logger.e("FridgeRepository => NO API TOKEN FOUND IN CACHE");
      throw FailedToFetchApiTokenException();
    }
    return token;
  }

  Future<Map<int, Item>> fetchAll() async {
    throw Exception("Not Implented");
  }

  Item get(int id) {
    throw Exception("Not Implented");
  }

  Map<int, Item> getAll() {
    throw Exception("Not Implemented");
  }

  Future<int> add(Item item) async {
    throw Exception("Not Implented");
  }

  Future<bool> delete(int id) async {
    throw Exception("Not Implented");
  }
}
