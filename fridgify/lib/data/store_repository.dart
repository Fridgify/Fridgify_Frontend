import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/store.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StoreRepository implements Repository<Store, int> {
  Logger logger = Repository.logger;
  SharedPreferences sharedPreferences = Repository.sharedPreferences;
  Dio dio;

  static const storeApi = "${Repository.baseURL}stores/";

  Map<int, Store> stores = Map();
  Map<Store, String> storeWithNames = Map();

  static final StoreRepository _storeRepository = StoreRepository._internal();

  factory StoreRepository([Client client]) {
    _storeRepository.dio = Repository.getDio();

    return _storeRepository;
  }

  StoreRepository._internal();

  Future<Store> getByName(String name) async {
    if(this.getAllWithName().values.contains(name)) {
      print("Found");
      return this.getAllWithName().keys.firstWhere((element) => element.name == name);
    }
    print("Not Found");
    Store s = Store.create(name: name);
    stores[await add(s)] = s;
    return s;
  }

  @override
  Future<int> add(Store store) async {
    var response = await dio.post(storeApi,
        data: jsonEncode({
          "name": store.name,
        }),
        options: Options(headers: Repository.getHeaders())
    );

    logger.i('StoreRepository => ADDING STORE: ${response.data}');

    if (response.statusCode == 201) {
      var s = response.data;
      var store = Store(storeId: s['store_id'], name: s['name']);
      logger.i("StoreRepository => CREATED SUCCESSFUL $store");

      this.stores[store.storeId] = store;

      return store.storeId;
    }

    throw FailedToAddContentException();
  }

  @override
  Future<bool> delete(int id) {
    // TODO: implement delete
    return null;
  }

  @override
  Future<Map<int, Store>> fetchAll() async {
    logger.i('StoreRepository => FETCHING FROM URL: $storeApi');

    var response = await dio.get(storeApi,
        options: Options(headers: Repository.getHeaders())
    );

    logger.i('StoreRepository => FETCHING STORES: ${response.data}');

    if (response.statusCode == 200) {
      var stores = response.data;

      logger.i('StoreRepository => $stores');

      for (var store in stores) {
        logger.i("StoreRepository => FETCHED STORES: $store");
        Store s = Store(storeId: store['store_id'], name: store['name']);

        this.storeWithNames[s] = s.name;
        this.stores[s.storeId] = s;
      }

      logger.i("StoreRepository => FETCHED ${this.stores.length} ITEMS");
      return this.stores;
    }
    throw new FailedToFetchContentException();
  }

  @override
  get(int id) {
    return this.stores[id];
  }

  Map<Store, String> getAllWithName() {
    return storeWithNames;
  }

  @override
  Map<int, Store> getAll() {
    return this.stores;
  }
}
