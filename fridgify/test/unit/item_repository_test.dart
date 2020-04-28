import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/store.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  ItemRepository itemRepository;
  ItemRepositoryTestUtil testUtil;
  MockClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    testUtil = ItemRepositoryTestUtil();

    mockClient = new MockClient((request) async {
      switch (request.method) {
        case "GET":
          return testUtil.handleGETRequest(request);
        case 'POST':
          return testUtil.handlePOSTRequest(request);
        case 'PATCH':
          return testUtil.handlePATCHRequest(request);
        case 'DELETE':
          return testUtil.handleDELETERequest(request);
        default:
          return Response('Not implemented', 201);
      }
    });

    itemRepository = ItemRepository(mockClient);
  });

  group('fetchAll', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case fetch all');

      expect(
          () async => completion(await itemRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('adds all of the returned content', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Add items');

      testUtil.setupStore(itemRepository, 2);
      var content = await itemRepository.fetchAll();

      // Should have 88 entries
      for (int i = 0; i < 88; i++) {
        expect(true, itemRepository.items.containsKey(i));
      }
    });
  });
}

class ItemRepositoryTestUtil {
  ItemRepositoryTestUtil();

  Response handleGETRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case fetch all':
        return Response('Error case fetch all', 404);
      case 'Add items':
        return Response(json.encode(createItemObjects(88)), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handlePOSTRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case add content':
        return Response('Error case add content', 404);
      case 'Create':
        return Response(json.encode({'message': 'created'}), 201);
      case 'Set date':
        return Response(json.encode({'message': 'created'}), 201);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handlePATCHRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case update content':
        return Response('Error case update content', 404);
      case 'Update':
        return Response(json.encode(''), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handleDELETERequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Doesnt delete':
        return Response('Doesnt delete', 404);
      case 'Delete':
        return Response('', 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  List<Object> createItemObjects(int amount) {
    List<Object> content = List();

    for (int i = 0; i < amount; i++) {
      content.add({
        'item_id': i,
        'barcode': 'wdawd',
        'name': 'Item No. $i',
        'description': 'Human part No. $i',
        'store': 2,
      });
    }

    return content;
  }

  void setupStore(ItemRepository itemRepository, int id) {
    itemRepository.storeRepository.stores.putIfAbsent(
        id,
        () => Store(
              storeId: id,
              name: 'Ikea',
            ));
  }
}
