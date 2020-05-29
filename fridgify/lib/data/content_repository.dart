import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridgify/model/item.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortedmap/sortedmap.dart';

import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';

class ContentRepository implements Repository<Content, String> {
  Logger logger = Repository.logger;

  Fridge fridge;
  SharedPreferences pref = Repository.sharedPreferences;
  ItemRepository itemRepository = ItemRepository();
  Dio dio;

  Map<String, Content> contents = Map();
  SortedMap<String, List<Content>> grouped = SortedMap(Ordering.byKey());

  var contentApi;

  ContentRepository(this.pref, this.fridge, [Dio dio]) {
    contentApi = "${Repository.baseURL}fridge/content/${this.fridge.fridgeId}/";

    this.dio = Repository.getDio(dio);
  }

  @override
  Future<String> add(Content content) async {
    var body = content.toString();
    logger.i('ContentRepository => Requesting $contentApi with $body');

    var response = await dio.post(contentApi, options: Options(headers: Repository.getHeaders()), data: body);

    logger.i('ContentRepository => CREATING CONTENT: ${response.data}');

    if (response.statusCode == 201) {
      var c = response.data;

      logger.i("ContentRepository => CREATED SUCCESSFUL $c");

      itemRepository.addSync(Item.create(
        name: content.item.name,
        store: content.item.store,
        barcode: "",
        itemId: c[0]['item'],
      ));

      this.contents.addAll(Map.fromIterable(c, key: (k) => k['content_id'],
          value: (v) => Content.fromJson(v, this.fridge)));

      group();

      return "Added";
    }

    throw FailedToAddContentException();
  }

  @override
  Future<bool> delete(String id) async {
    var response =
        await dio.delete("$contentApi$id", options: Options(headers: Repository.getHeaders()));

    logger.i(
        'ContentRepository => DELETING CONTENT: ${response.data} ${response.statusCode} ON URL $contentApi$id');

    if (response.statusCode == 200) {
      logger.i('FridgeRepository => DELETED CONTENT');
      removeFromGroup(this.get(id));
      this.contents.remove(id);
      return true;
    }

    return false;
  }

  @override
  Future<Map<String, Content>> fetchAll() async {
    logger.i('ContentRepository => FETCHIN FROM URL: $contentApi');
    this.grouped = SortedMap(Ordering.byKey());

    var response =
        await dio.get(contentApi, options: Options(headers: Repository.getHeaders()));

    logger.i('ContentRepository => FETCHING CONTENT: ${response.data}');

    if (response.statusCode == 200) {
      var contents = response.data as List;

      logger.i('ContentRepository => $contents');

      this.contents = Map.fromIterable(contents,
          key: (e) => e['content_id'], value: (e) => Content.fromJson(e, this.fridge));

      logger.i("ContentRepository => FETCHED ${this.contents.length} CONTENTS");
      group();
      return this.contents;
    }
    throw new FailedToFetchContentException();
  }

  @override
  Content get(String id) {
    return this.contents[id];
  }

  @override
  Map<String, Content> getAll() {
    return this.contents;
  }

  Future<Content> withdraw(Content content, int amount) async {
    logger.i(
        'ContentRepository => WITHDRAWING $amount FROM ${content.item.name} ${content.amount} FROM URL: $contentApi');

    var response = await dio.patch('$contentApi${content.contentId}', options: Options(headers: Repository.getHeaders()), data: jsonEncode({'withdraw': amount}));

    logger.i('ContentRepository => WITHDRAWING CONTENT: ${response.data}');


    if (response.statusCode == 200) {
      var contents = response.data;

      logger.i('ContentRepository => WITHDRAW SUCCESSFUL $contents');
      if(content.amount <= 0)
      {
        logger.i("Empty delete");
        this.contents.remove(content.contentId);
        removeFromGroup(content);
      }
      else {
        this.contents[content.contentId] = content;
      }
      return content;
    }
    throw new FailedToFetchContentException();
  }

  Future<Content> update(
      Content content, dynamic attribute, String parameter) async {
    logger.i(
        'ContentRepository => UPDATING CONTENT $attribute with $parameter FROM URL: $contentApi');

    var response = await dio.patch('$contentApi${content.item.itemId}', options: Options(headers: Repository.getHeaders()), data: jsonEncode({attribute: parameter}));

    logger.i('ContentRepository => PATCHING CONTENT: ${response.data}');


    if (response.statusCode == 200) {
      var contents = response.data;

      logger.i('ContentRepository => UPDATED SUCCESSFUL $contents');

      return content;
    }
    throw new FailedToFetchContentException();
  }

  void group() {

    this.getAll().forEach((key, value) =>
    {
      if(value.item != null) {
        this.addToGroup(value)
      }
      else {
        logger.e("ContentRepository => ERROR OCCURED WHILE CREATING GROUP FOR VALUE $value")
      }
    });
    logger.i("ContentRepository => CREATED GROUP ${this.grouped.length}");
  }

  void addToGroup(Content c) {
    if(grouped.containsKey(c.item.name)) {
      grouped[c.item.name].add(c);
    }
    else
    {
      List<Content> tmp = List<Content>();
      tmp.add(c);
      grouped[c.item.name] = tmp;
    }
  }

  void removeFromGroup(Content c) {
    if(grouped.containsKey(c.item.name)) {
      grouped[c.item.name].remove(c);
      if(grouped[c.item.name].length == 0)
        {
          grouped.remove(c.item.name);
        }
    }
  }

  SortedMap<String, List<Content>> getAsGroup() {
    return grouped;
  }
}
