import 'dart:convert';

import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_fridges_exception.dart';
import 'package:fridgify/model/fridge.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeRepository implements Repository<Fridge> {
  Logger logger = Repository.logger;

  Map<int, Fridge> fridges = Map();

  static const fridgeAPI = "${Repository.baseURL}/fridge/";

  static final FridgeRepository _fridgeRepository =
      FridgeRepository._internal();

  factory FridgeRepository() {
    return _fridgeRepository;
  }

  FridgeRepository._internal();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  @override
  Future<int> add(Fridge f) async {
    var response = await http.post("${fridgeAPI}management/create/",
        headers: Repository.getHeaders(),
        body: jsonEncode({
          "fridge_id": f.fridgeId,
          "name": f.name,
          "description": f.description
        }),
        encoding: utf8);

    logger.i('FridgeRepository => CREATING FRIDGE: ${response.body}');

    if (response.statusCode == 201) {
      var f = jsonDecode(response.body);
      var fridge = Fridge.create(
          fridgeId: f["fridge_id"],
          name: f["name"],
          description: f["description"]);
      logger.i("FridgeRepository => CREATED SUCCESSFUL $fridge");

      this.fridges[fridge.fridgeId] = fridge;

      return fridge.fridgeId;
    }

    throw FailedToCreateNewFridgeException();
  }

  @override
  Future<bool> delete(int id) async {
    var response = await http.delete("$fridgeAPI/management/$id/",
        headers: Repository.getHeaders());

    logger.i('FridgeRepository => DELETING FRIDGE: ${response.body}');

    if (response.statusCode == 200) {
      logger.i('FridgeRepository => DELETED FRIDGE');
      this.fridges.remove(id);
      return true;
    }

    return false;
  }

  @override
  Future<Map<int, Fridge>> fetchAll() async {
    var response = await http.get(fridgeAPI, headers: Repository.getHeaders());
    logger.i('FridgeRepository => FETCHING FRIDGES: ${response.body}');

    if (response.statusCode == 200) {
      var fridges = jsonDecode(response.body);

      logger.i('FridgeRepository => $fridges');

      for (var fridge in fridges) {
        Fridge f = Fridge(
            fridgeId: fridge['id'],
            name: fridge['name'],
            description: fridge['description'],
            content: fridge['content']);
        f.contentRepository = ContentRepository(sharedPreferences, f);

        logger.i("FridgeRepository => FETCHED FRIDGE: $f");

        this.fridges[fridge['id']] = f;
      }

      logger.i("FridgeRepository => FETCHED ${this.fridges.length} FRIDGES");

      return this.fridges;
    }
    throw new FailedToFetchFridgesException();
  }

  @override
  get(int id) {
    return this.fridges[id];
  }

  @override
  Map<int, Fridge> getAll() {
    return this.fridges;
  }
}
