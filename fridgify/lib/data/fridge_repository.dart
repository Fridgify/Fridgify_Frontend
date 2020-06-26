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
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/permission_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeRepository implements Repository<Fridge, int> {

  Logger _logger = Logger('FridgeRepository');

  UserService _userService = UserService();

  Map<int, Fridge> fridges = Map();
  Dio dio;

  static final fridgeAPI = "${Repository.baseURL}fridge/";
  static final String userManagementApi = "${fridgeAPI}management";

  static final FridgeRepository _fridgeRepository =
      FridgeRepository._internal();

  factory FridgeRepository([Dio dio]) {
    _fridgeRepository.dio = Repository.getDio(dio);

    return _fridgeRepository;
  }

  FridgeRepository._internal();

  SharedPreferences sharedPreferences = Repository.sharedPreferences;

  Future<Fridge> update(
      Fridge fridge, dynamic attribute, String parameter) async {
    _logger.i(
        'UPDATING FRIDGE $attribute with $parameter FROM URL: $userManagementApi/${fridge.fridgeId}/ FOR ${fridge.fridgeId}');

    var response = await dio.patch('$userManagementApi/${fridge.fridgeId}/',
        options: Options(headers: Repository.getHeaders()),
        data: jsonEncode({attribute: parameter, "fridge_id": fridge.fridgeId}));

    _logger.i('PATCHING FRIDGE: ${response.data} ${response.statusCode}');

    if (response.statusCode == 200) {
      var contents = response.data;

      _logger.i('UPDATED SUCCESSFUL $contents');

      fridge.name = parameter;

      this.fridges[fridge.fridgeId] = fridge;

      return fridge;
    }
    throw new FailedToFetchContentException();
  }

  @override
  Future<int> add(Fridge f) async {
    var response = await dio.post("${fridgeAPI}management/create/",
        data: jsonEncode({"fridge_id": f.fridgeId, "name": f.name}),
        options: Options(headers: Repository.getHeaders())
    );

    _logger.i('CREATING FRIDGE: ${response.data}');

    if (response.statusCode == 201) {
      var f = response.data;
      var fridge = Fridge.create(fridgeId: f["fridge_id"], name: f["name"]);
      _logger.i("CREATED SUCCESSFUL $fridge");

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

    throw FailedToCreateNewFridgeException(response.data);
  }

  @override
  Future<bool> delete(int id) async {
    var response = await dio.delete("$fridgeAPI/management/$id/",
        options: Options(headers: Repository.getHeaders())
    );

    _logger.i('DELETING FRIDGE: ${response.data}');

    if (response.statusCode == 200) {
      _logger.i('DELETED FRIDGE');
      this.fridges.remove(id);
      return true;
    }

    return false;
  }

  Future<Fridge> initFridge(dynamic json) async {
    Fridge f = Fridge.fromJson(json);
    f.contentRepository = ContentRepository(sharedPreferences, f, dio);

    f.members = await getUsersForFridge(f.fridgeId);
    await f.contentRepository.fetchAll();

    return f;
  }

  @override
  Future<Map<int, Fridge>> fetchAll() async {
    var response = await dio.get(fridgeAPI,
        options: Options(headers: Repository.getHeaders())
    );
    _logger.i('FETCHING FRIDGES: ${response.data}');

    if (response.statusCode == 200) {
      List fridges = response.data;

      _logger.i('$fridges');

      Iterable<Future<Fridge>> temp = fridges.map((e) async => await initFridge(e));
      this.fridges = Map.fromIterable(await Future.wait(temp), key: (e) => e.fridgeId, value: (e) => e);


      _logger.i("FETCHED ${this.fridges.length} FRIDGES");

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
    var userUrl = "$userManagementApi/$fridgeId/users";


    _logger.i('FETCHING USERS FROM URL: $userUrl');

    var response = await dio.get('$userUrl', options: Options(headers: Repository.getHeaders()));

    _logger.i(
        'FETCHING USERS FOR FRIDGE $fridgeId: ${response.data}');

    if (response.statusCode == 200) {
      var users = response.data;

      usersList = Map.fromIterable(users, key: (e) => User.fromJson(e['user']), value: (e) => Permissions.user.byName(e['role']));

      _logger.i('${usersList.length}');
      return usersList;
    }
    throw new FailedToFetchContentException();
  }

  Future<Fridge> joinByUrl(Uri url) async {
    _logger.i('JOINING FRIDGE VIA INVITE URL $url');

    var response = await dio.get(url.toString(), options: Options(headers: Repository.getHeaders()));

    _logger.i('JOINED FRIDGE ${response.data}');

    if(response.statusCode == 201){
      var fridge = response.data;

      Fridge f = Fridge.fromJson(fridge);

      f.contentRepository = ContentRepository(sharedPreferences, f, dio);

      f.members = await getUsersForFridge(f.fridgeId);
      await f.contentRepository.fetchAll();

      this.fridges[f.fridgeId] = f;
      return f;
    }

    throw FailedToCreateNewFridgeException(response.data);

  }
}
