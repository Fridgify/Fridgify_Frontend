import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_fridges_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/permission_helper.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeRepository implements Repository<Fridge, int> {
  Logger logger = Repository.logger;

  UserService _userService = UserService();

  Map<int, Fridge> fridges = Map();
  Dio dio;

  static const fridgeAPI = "${Repository.baseURL}/fridge/";
  static const String userManagementApi = "${fridgeAPI}management/";

  static final FridgeRepository _fridgeRepository =
      FridgeRepository._internal();

  factory FridgeRepository([Dio dio]) {
    _fridgeRepository.dio = Repository.getDio(dio);

    return _fridgeRepository;
  }

  FridgeRepository._internal();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  @override
  Future<int> add(Fridge f) async {
    var response = await dio.post("${fridgeAPI}management/create/",
        data: jsonEncode({"fridge_id": f.fridgeId, "name": f.name}),
        options: Options(headers: Repository.getHeaders())
    );

    logger.i('FridgeRepository => CREATING FRIDGE: ${response.data}');

    if (response.statusCode == 201) {
      var f = response.data;
      var fridge = Fridge.create(fridgeId: f["fridge_id"], name: f["name"]);
      logger.i("FridgeRepository => CREATED SUCCESSFUL $fridge");

      fridge.content = {
        'total': 0,
        'fresh': 0,
        'dueSoon': 0,
        'overDue': 0,
      };

      fridge.members[_userService.get()] = Permissions.owner;

      fridge.contentRepository = ContentRepository(sharedPreferences, fridge);

      this.fridges[fridge.fridgeId] = fridge;

      return fridge.fridgeId;
    }

    throw FailedToCreateNewFridgeException();
  }

  @override
  Future<bool> delete(int id) async {
    var response = await dio.delete("$fridgeAPI/management/$id/",
        options: Options(headers: Repository.getHeaders())
    );

    logger.i('FridgeRepository => DELETING FRIDGE: ${response.data}');

    if (response.statusCode == 200) {
      logger.i('FridgeRepository => DELETED FRIDGE');
      this.fridges.remove(id);
      return true;
    }

    return false;
  }

  @override
  Future<Map<int, Fridge>> fetchAll() async {
    var response = await dio.get(fridgeAPI,
        options: Options(headers: Repository.getHeaders())
    );
    logger.i('FridgeRepository => FETCHING FRIDGES: ${response.data}');

    if (response.statusCode == 200) {
      var fridges = response.data;

      logger.i('FridgeRepository => $fridges');

      for (var fridge in fridges) {
        Fridge f = Fridge(
            fridgeId: fridge['id'],
            name: fridge['name'],
            content: fridge['content']);
        f.contentRepository = ContentRepository(sharedPreferences, f, dio);

        f.members = await getUsersForFridge(f.fridgeId);
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
  Future<Map<User, Permissions>> getUsersForFridge(int fridgeId) async {
    Map<User, Permissions> usersList = Map();
    var userUrl = "$userManagementApi$fridgeId/users";


    logger.i('UserService => FETCHING USERS FROM URL: $userUrl');

    var response = await dio.get('$userUrl', options: Options(headers: Repository.getHeaders()));

    logger.i(
        'UserService => FETCHING USERS FOR FRIDGE $fridgeId: ${response.data}');

    if (response.statusCode == 200) {
      var users = response.data;
      for (var us in users) {
        var user = us['user'];
        User u = User.noPassword(
          username: user['username'],
          name: user['name'],
          surname: user['surname'],
          email: user['email'],
          birthDate: user['birth_date'],
          userId: user['user_id'],
        );
        logger.i('UserService => FOUND USER $u ROLE ${us['role']}');

        usersList[u] = Permissions.user.byName(us['role']);
      }

      logger.i('UserService => ${usersList.length}');
      return usersList;
    }
    throw new FailedToFetchContentException();
  }

  Future<Fridge> joinByUrl(Uri url) async {
    logger.i('FridgeRepository => JOINING FRIDGE VIA INVITE URL $url');

    var response = await dio.get(url.toString(), options: Options(headers: Repository.getHeaders()));

    logger.i('UserService => JOINED FRIDGE ${response.data}');

    if(response.statusCode == 201){
      var fridge = response.data;

      Fridge f = Fridge(
          fridgeId: fridge['id'],
          name: fridge['name'],
          content: fridge['content']
      );

      f.contentRepository = ContentRepository(sharedPreferences, f, dio);

      f.members = await getUsersForFridge(f.fridgeId);
      await f.contentRepository.fetchAll();

      this.fridges[f.fridgeId] = f;
      return f;
    }

    throw new FailedToCreateNewFridgeException();

  }
  /*Future<List<User>> getFridgeMembers(Fridge f) async {
    List<User> member = List();
    var url = Repository.baseURL + 'users/${f.fridgeId}/';

    logger.i(
        'FridgeRepository => FETCHING USER FOR FRIDGE ${f.fridgeId} ON URL $url');

    var response = await dio.get(url,
        options: Options(headers: Repository.getHeaders())
    );
    logger.i('FridgeRepository => FETCHING USERS : ${response.data}');

    if (response.statusCode == 200) {
      var users = response.data;

      logger.i('FridgeRepository => $users');

      for (var user in users) {
        logger.i("FridgeRepository => FETCHED USER: $user");

        User u = User.noPassword(username: user['username'], name: user['name'],
            surname: user['surname'], email: user['email'], birthDate: user['birth_date'],
          userId: user['user_id'],);

        member.add(u);
      }

      logger.i("FridgeRepository => FETCHED ${member.length} MEMBERS");

      f.member = member;

      return member;
    }
    throw new FailedToFetchFridgesException();
  }*/
}
