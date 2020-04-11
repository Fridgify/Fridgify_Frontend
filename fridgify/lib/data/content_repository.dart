
import 'dart:convert';

import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ContentRepository implements Repository<Content> {

  Logger logger = Repository.logger;

  Fridge fridge;
  SharedPreferences pref = Repository.sharedPreferences;
  ItemRepository itemRepository = ItemRepository();

  Map<int, Content> contents = Map();

  var contentApi;

  ContentRepository(this.pref, this.fridge) {
    contentApi = "${Repository.baseURL}fridge/content/${this.fridge.fridgeId}/";
  }

  @override
  Future<int> add (Content content) async {
    var date = DateTime.now();

    var token = Repository.getToken();
    var body = jsonEncode({
      "name": content.item.name, "description": content.item.description,
      "buy_date": "${date.year}-${date.month}-${date.day}",
      "expiration_date": content.expirationDate,
      "amount": content.amount,
      "unit": content.unit, "store": content.item.store.name,
    });
    logger.i('ContentRepository => Requesting $contentApi with $body');

    var response = await http.post(
        contentApi, headers: {
      "Content-Type": "application/json",
      "Authorization": token
    }, body: body,
      encoding: utf8
    );

    logger.i('ContentRepository => CREATING CONTENT: ${response.body}');

    if (response.statusCode == 201) {
      var c = jsonDecode(response.body);

      logger.i("ContentRepository => CREATED SUCCESSFUL $c");

      return fridge.fridgeId;
    }

    throw FailedToAddContentException();
  }

  @override
  Future<bool> delete(int id) async {
    var token = Repository.getToken();

    var response = await http.delete(
        "$contentApi$id", headers: {
      "Content-Type": "application/json",
      "Authorization": token
    });

    logger.i('ContentRepository => DELETING CONTENT: ${response.body} ON URL $contentApi$id');

    if (response.statusCode == 200) {
      logger.i('FridgeRepository => DELETED CONTENT');
      this.contents.remove(id);
      return true;
    }

    return false;
  }

  @override
  Future<Map<int, Content>> fetchAll() async {
    var token = Repository.getToken();

    logger.i('ContentRepository => FETCHIN FROM URL: $contentApi');

    var response = await http.get(
        contentApi, headers: {
      "Content-Type": "application/json",
      "Authorization": token
    });

    logger.i('ContentRepository => FETCHING CONTENT: ${response.body}');

    if(response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => $contents');


      for(var content in contents) {
        Content c = Content(expirationDate: content['expiration_date'], amount: content['amount'],
            unit: content['unit'],
            fridge: this.fridge, item: itemRepository.get(content['item_id']));
        this.contents[c.item.itemId] = c;
      }

      logger.i("ContentRepository => FETCHED ${this.contents.length} CONTENTS");
      return this.contents;

    }
    throw new FailedToFetchContentException();
  }

  @override
  Content get(int id) {
    return this.contents[id];
  }

  @override
  Map<int, Content> getAll() {
    return this.contents;
  }

  Future<Content> update(Content content, dynamic attribute, String parameter) async {
    var token = Repository.getToken();

    logger.i('ContentRepository => UPDATING CONTENT $parameter with $attribute FROM URL: $contentApi');

    var response = await http.patch(
        '$contentApi${content.item.itemId}', headers: {
      "Content-Type": "application/json",
      "Authorization": token
    },
    body: jsonEncode({
        parameter: attribute
      }),
      encoding: utf8
    );

    logger.i('ContentRepository => PATCHING CONTENT: ${response.body}');

    if(response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => UPDATED SUCCESSFUL $contents');

      this.contents[content.item.itemId] = content;
      return content;
    }
    throw new FailedToFetchContentException();

  }

}