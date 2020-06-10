import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/model/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  ItemRepository itemRepository;
  ItemRepositoryTestUtil testUtil;
  Dio mockDio;
  Repository.isTest = true;

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
        case 'Barcode':
          return testUtil.handleBarcodeRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    itemRepository = ItemRepository(mockDio);
  });

  group('Standard repository function', () {
    test('delete, does nothing', () async {
      expect(Future.value(null), completion(await itemRepository.delete(1)));
    });

    test('getAll, gets two items', () async {
      itemRepository.items.clear();
      itemRepository.items.putIfAbsent(
          1,
          () => Item(
              itemId: 1,
              barcode: 'null',
              name: 'null',
              store: Store(storeId: 25, name: 'null')));
      itemRepository.items.putIfAbsent(
          2,
          () => Item(
              itemId: 2,
              barcode: 'null',
              name: 'null',
              store: Store(storeId: 25, name: 'null')));
      expect(2, itemRepository.items.length);
    });

    test('add, does nothing', () async {
      expect(
          () async => completion(await itemRepository.add(Item(
              itemId: 1,
              barcode: 'null',
              name: 'null',
              store: Store(storeId: 25, name: 'null')))),
          throwsA(predicate((error) => error is UnimplementedError)));
    });
  });

  group('barcode', () {
    setUp(() {
      testUtil.setTestCase('Barcode');
    });

    test('returns no item', () async {
      testUtil.setId('Returns no item');

      expect(Future.value(null),
          completion(await itemRepository.barcode('barcode')));
    });

    test('returns an item', () async {
      testUtil.setId('Returns an item');

      Item item = Item.fromJson({
        'item_id': 15,
        'barcode': 'wdawd',
        'name': 'Item 1',
        'description': 'Human part No. Q',
        'store': 2
      });

      Item returnedItem = await itemRepository.barcode('barcode');
      expect(item.toString(), returnedItem.toString());
    });
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
  ItemRepositoryTestUtil(Dio dio) : super(dio);

  Response handleBarcodeRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Returns no item':
        return Response(data: 'Returns no item', statusCode: 404);
      case 'Returns an item':
        return Response(data: {
          'item_id': 15,
          'barcode': 'wdawd',
          'name': 'Item 1',
          'description': 'Human part No. Q',
          'store': 2
        }, statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

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
