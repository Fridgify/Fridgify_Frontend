import 'dart:collection';
import 'dart:convert';

import 'package:fridgify/cache/http_client_interceptor.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortedmap/sortedmap.dart';

class ContentRepository implements Repository<Content, String> {
  Logger logger = Repository.logger;

  Fridge fridge;
  SharedPreferences pref = Repository.sharedPreferences;
  ItemRepository itemRepository = ItemRepository();
  Client client;

  Map<String, Content> contents = Map();
  SortedMap<String, List<Content>> grouped = SortedMap(Ordering.byKey());

  var contentApi;

  ContentRepository(this.pref, this.fridge, [Client client]) {
    contentApi = "${Repository.baseURL}fridge/content/${this.fridge.fridgeId}/";

    this.client = Repository.getClient(client);
  }

  @override
  Future<String> add(Content content) async {
    var date = DateTime.now();
    var body = jsonEncode({
      "name": content.item.name,
      "buy_date": "${date.year}-${date.month < 10 ? "0${date.month}" : date.month}-${date.day}",
      "expiration_date": content.expirationDate,
      "count": content.count,
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
      for(var con in c) {
        Content temp = Content(amount: content.amount, contentId: con['content_id'],
          expirationDate: content.expirationDate, fridge: content.fridge, item: content.item, maxAmount: content.maxAmount, unit: content.unit,);
        this.contents[content.contentId] = temp;
      }
      group(this.getAll());
      return "Added";
    }

    throw FailedToAddContentException();
  }

  @override
  Future<bool> delete(String id) async {
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
  Future<Map<String, Content>> fetchAll() async {
    logger.i('ContentRepository => FETCHIN FROM URL: $contentApi');

    var response =
        await client.get(contentApi, headers: Repository.getHeaders());

    logger.i('ContentRepository => FETCHING CONTENT: ${response.body}');

    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => $contents');

      for (var content in contents) {
        Content c = Content(
            contentId: content['content_id'],
            expirationDate: content['expiration_date'],
            amount: content['amount'],
            maxAmount: content['max_amount'],
            unit: content['unit'],
            fridge: this.fridge,
            item: itemRepository.get(content['item_id']));
        this.contents[c.contentId] = c;
      }

        logger.i("ContentRepository => FETCHED ${this.contents.length} CONTENTS");
        group(this.contents);
      return this.contents;
    }
    throw new FailedToFetchContentException();
  }

  void group(var all) {
    SortedMap<String, List<Content>> ret = SortedMap(Ordering.byKey());
    List<Content> tmp = List();

    this.getAll().forEach((key, value) =>
    {
      if(value.item != null) {

        if(ret.containsKey(value.item.name)) {
          ret[value.item.name].add(value),
        }
        else
          {
            tmp = List(),
            tmp.add(value),
            ret[value.item.name] = tmp,
          }
      }
      else {
        logger.e("ContentRepository => ERROR OCCURED WHILE CREATING GROUP FOR VALUE $value")
      }
    });
    grouped = ret;
  }

  @override
  Content get(String id) {
    return this.contents[id];
  }

  @override
  Map<String, Content> getAll() {
    return this.contents;
  }
  Future<Content> withdraw(
      Content content, int amount) async {
    logger.i(
        'ContentRepository => WITHDRAWING $amount FROM ${content.item.name} ${content.amount} FROM URL: $contentApi');

    var response = await client.patch('$contentApi${content.contentId}',
        headers: Repository.getHeaders(),
        body: jsonEncode({'withdraw': amount}),
        encoding: utf8);

    logger.i('ContentRepository => WITHDRAWING CONTENT: ${response.body}');


    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => WITHDRAW SUCCESSFUL $contents');
      if(content.amount <= 0)
      {
        logger.i("Empty delete");
        this.contents.remove(content.contentId);
        group(this.contents);
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

    var response = await client.patch('$contentApi${content.item.itemId}',
        headers: Repository.getHeaders(),
        body: jsonEncode({attribute: parameter}),
        encoding: utf8);

    logger.i('ContentRepository => PATCHING CONTENT: ${response.body}');


    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      logger.i('ContentRepository => UPDATED SUCCESSFUL $contents');

      return content;
    }
    throw new FailedToFetchContentException();
  }

  SortedMap<String, List<Content>> getAsGroup() {
    return grouped;
  }
}
