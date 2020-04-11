import 'package:shared_preferences/shared_preferences.dart';

abstract class Repository <Item> {
  static const baseURL = "https://fridgapi-dev.donkz.dev/";
  static SharedPreferences sharedPreferences;

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