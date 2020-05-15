import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/store.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  ItemRepository itemRepository;
  ItemRepositoryTestUtil testUtil;
  Dio mockDio;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences.setString('apiToken', 'Test token');

    mockDio = new Dio();
    testUtil = ItemRepositoryTestUtil(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {
      switch (request.extra['testCase']) {
        case 'Fetch all':
          return testUtil.handleFetchAllRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    itemRepository = ItemRepository(mockDio);
  });

  group('fetchAll', () {
    setUp(() {
      testUtil.setTestCase('Fetch all');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch all');

      expect(
          () async => completion(await itemRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('adds all of the returned content', () async {
      testUtil.setId('Add items');

      testUtil.setupStore(itemRepository, 2);
      var content = await itemRepository.fetchAll();

      // Should have 88 entries
      for (int i = 0; i < 88; i++) {
        expect(true, itemRepository.items.containsKey(i));
      }
    });
  });
}

class ItemRepositoryTestUtil extends TestUtil {
  ItemRepositoryTestUtil(Dio dio): super(dio);

  Response handleFetchAllRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch all':
        return Response(data: 'Error case fetch all', statusCode: 404);
      case 'Add items':
        return Response(data: createItemObjects(88), statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
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
