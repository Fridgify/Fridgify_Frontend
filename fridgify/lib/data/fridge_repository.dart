import 'dart:convert';

import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_fridges_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeRepository implements Repository<Fridge> {
  Logger logger = Repository.logger;

  UserService _userService = UserService();

  Map<int, Fridge> fridges = Map();
  Client client;

  static const fridgeAPI = "${Repository.baseURL}/fridge/";

  static final FridgeRepository _fridgeRepository =
      FridgeRepository._internal();

  factory FridgeRepository([Client client]) {
    if (client != null) {
      _fridgeRepository.client = client;
    } else {
      _fridgeRepository.client = Client();
    }

    return _fridgeRepository;
  }

  FridgeRepository._internal();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  @override
  Future<int> add(Fridge f) async {
    var response = await client.post("${fridgeAPI}management/create/",
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

      fridge.content = {
        'total': 0,
        'fresh': 0,
        'dueSoon': 0,
        'overDue': 0,
      };

      fridge.member.add(_userService.get());

      fridge.contentRepository = ContentRepository(sharedPreferences, fridge);

      this.fridges[fridge.fridgeId] = fridge;



      return fridge.fridgeId;
    }

    throw FailedToCreateNewFridgeException();
  }

  @override
  Future<bool> delete(int id) async {
    var response = await client.delete("$fridgeAPI/management/$id/",
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
    var response = await client.get(fridgeAPI, headers: Repository.getHeaders());
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
        f.contentRepository = ContentRepository(sharedPreferences, f, client);

        await getFridgeMembers(f);
        await f.contentRepository.fetchAll();

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

  Future<List<User>> getFridgeMembers(Fridge f) async {
    List<User> member = List();
    var url = Repository.baseURL + 'users/${f.fridgeId}/';

    logger.i('FridgeRepository => FETCHING USER FOR FRIDGE ${f.fridgeId} ON URL $url');

    var response = await client.get(url, headers: Repository.getHeaders());
    logger.i('FridgeRepository => FETCHING USERS : ${response.body}');

    if (response.statusCode == 200) {
      var users = jsonDecode(response.body);

      logger.i('FridgeRepository => $users');

      for (var user in users) {
        logger.i("FridgeRepository => FETCHED USER: $user");

        User u = User.noPassword(username: user['username'], name: user['name'],
            surname: user['surname'], email: user['email'], birthDate: user['birth_date']);

        member.add(u);
      }

      logger.i("FridgeRepository => FETCHED ${member.length} MEMBERS");

      f.member = member;

      return member;
    }
    throw new FailedToFetchFridgesException();
  }
}
