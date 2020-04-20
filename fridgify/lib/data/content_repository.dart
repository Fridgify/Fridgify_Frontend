import 'dart:convert';

import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:http/http.dart';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentRepository implements Repository<Content> {
  Logger logger = Repository.logger;

  Fridge fridge;
  SharedPreferences pref = Repository.sharedPreferences;
  ItemRepository itemRepository = ItemRepository();
  Client client;

  Map<int, Content> contents = Map();

  var contentApi;

  ContentRepository(this.pref, this.fridge, [Client client]) {
    contentApi = "${Repository.baseURL}fridge/content/${this.fridge.fridgeId}/";

    if(client != null) {
      this.client = client;
    } else {
      this.client = Client();
    }
  }

  @override
  Future<int> add(Content content) async {
    var date = DateTime.now();
    var body = jsonEncode({
      "name": content.item.name,
      "description": content.item.description,
      "buy_date": "${date.year}-${date.month}-${date.day}",
      "expiration_date": content.expirationDate,
      "amount": content.amount,
      "unit": content.unit,
      "store": content.item.store.name,
    });
    logger.i('ContentRepository => Requesting $contentApi with $body');

    var response = await client.post(contentApi,
        headers: Repository.getHeaders(), body: body, encoding: utf8);

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
    var response =
        await client.delete("$contentApi$id", headers: Repository.getHeaders());

    logger.i(
        'ContentRepository => DELETING CONTENT: ${response.body} ON URL $contentApi$id');

    if (response.statusCode == 200) {
      logger.i('FridgeRepository => DELETED CONTENT');
      this.contents.remove(id);
      return true;
    }

    return false;
  }

  @override
  Future<Map<int, Content>> fetchAll() async {
    logger.i('ContentRepository => FETCHIN FROM URL: $contentApi');

    var response = await client.get(contentApi, headers: Repository.getHeaders());

    logger.i('ContentRepository => FETCHING CONTENT: ${response.body}');

    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => $contents');

      for (var content in contents) {
        Content c = Content(
            expirationDate: content['expiration_date'],
            amount: content['amount'],
            unit: content['unit'],
            fridge: this.fridge,
            item: itemRepository.get(content['item_id']));
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

  Future<Content> update(
      Content content, dynamic attribute, String parameter) async {
    logger.i(
        'ContentRepository => UPDATING CONTENT $parameter with $attribute FROM URL: $contentApi');

    var response = await client.patch('$contentApi${content.item.itemId}',
        headers: Repository.getHeaders(),
        body: jsonEncode({parameter: attribute}),
        encoding: utf8);

    logger.i('ContentRepository => PATCHING CONTENT: ${response.body}');

    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => UPDATED SUCCESSFUL $contents');

      this.contents[content.item.itemId] = content;
      return content;
    }
    throw new FailedToFetchContentException();
  }
}
