import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ItemRepository implements Repository<Item, int> {
  Fridge fridge;
  Logger _logger = Logger('ItemRepository');
  SharedPreferences sharedPreferences = Repository.sharedPreferences;
  StoreRepository storeRepository = StoreRepository();
  Dio dio;

  static final itemApi = "${Repository.baseURL}items/";

  Map<int, Item> items = Map();

  static final ItemRepository _itemRepository = ItemRepository._internal();

  factory ItemRepository([Dio dio]) {
    _itemRepository.dio = Repository.getDio(dio);
    return _itemRepository;
  }

  ItemRepository._internal();

  
  
  
  int addSync(item) {
    _logger.i("ADDING ITEM ${item.name} ${item.itemId}");
    this.items[item.itemId] = item;
    return item.itemId;
  }

  Future<Item> barcode(String barcode) async {
    var url = "${itemApi}barcode/$barcode";

    _logger.i('FETCHIN FROM BARCODE URL: $url');

    var response = await dio.get(url,
        options: Options(headers: Repository.getHeaders())
    );

    _logger.i('FETCHING BARCODE ITEM: ${response.data}');

    if (response.statusCode == 200) {
      var item = response.data;

      _logger.i('$item');

      return Item.fromJson(item);
    }
    return null;
  }

  @override
  Future<bool> delete(int id) async {
    // TODO: implement delete
    return null;
  }

  Future<Item> update(
      Item item, dynamic attribute, String parameter) async {
    _logger.i(
        'UPDATING Item $attribute with $parameter FROM URL: ${itemApi}id/${item.itemId}/ FOR ${item.itemId}');

    var response = await dio.patch('${itemApi}id/${item.itemId}',
        options: Options(headers: Repository.getHeaders()),
        data: jsonEncode({attribute: parameter, 'item_id':item.itemId}));

    _logger.i('PATCHING Item: ${response.data} ${response.statusCode}');

    if (response.statusCode == 200) {
      var contents = response.data;

      _logger.i('UPDATED SUCCESSFUL $contents');

      item.name = parameter;

      this.items[item.itemId] = item;

      return item;
    }
    throw new FailedToFetchContentException();
  }

  @override
  Future<Map<int, Item>> fetchAll() async {
    _logger.i('FETCHIN FROM URL: $itemApi');

    var response = await dio.get(itemApi,
        options: Options(headers: Repository.getHeaders())
    );

    _logger.i('FETCHING ITEMS: ${response.data}');

    if (response.statusCode == 200) {
      var items = response.data;

      _logger.i('$items');

      this.items = Map.fromIterable(items,
          key: (e) => e['item_id'], value: (e) => Item.fromJson(e));


      _logger.i("FETCHED ${this.items.length} ITEMS");
      return this.items;
    }
    throw new FailedToFetchContentException();
  }

  @override
  Item get(int id) {
    return this.items[id];
  }

  @override
  Map<int, Item> getAll() {
    return this.items;
  }

  @override
  Future<int> add(Item item) {
    // TODO: implement add
    throw UnimplementedError();
  }
}
