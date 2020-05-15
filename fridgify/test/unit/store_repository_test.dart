import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  StoreRepository storeRepository;
  StoreRepositoryTestUtil testUtil;
  Dio mockDio;
  Store store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences.setString('apiToken', 'Test token');

    mockDio = new Dio();
    testUtil = StoreRepositoryTestUtil(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {
      switch (request.extra['testCase']) {
        case "Add":
          return testUtil.handleAddRequest(request);
        case 'Fetch all':
          return testUtil.handleFetchAllRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    storeRepository = StoreRepository(mockDio);
    store = Store(storeId: 2, name: 'Ikea');

  });

  group('add', () {
    setUp(() {
      testUtil.setTestCase('Add');
    });

    test('throws an error', () async {
      testUtil.setId('Error case add store');

      expect(() async => completion(await storeRepository.add(store)),
          throwsA(predicate((error) => error is FailedToAddContentException)));
    });

    test('creates successfully', () async {
      testUtil.setId('Create store');

      expect(Future.value(2), completion(await storeRepository.add(store)));
      expect(true, storeRepository.stores.containsKey(2));
    });
    
  });

  group('fetchAll', () {
    setUp(() {
      testUtil.setTestCase('Fetch all');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch all');

      expect(
              () async => completion(await storeRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('adds all of the returned content', () async {
      testUtil.setId('Add content');

      var content = await storeRepository.fetchAll();

      // Should have 66 entries
      for (int i = 0; i < 123; i++) {
        expect(true, storeRepository.stores.containsKey(i));
      }
    });
  });

}

class StoreRepositoryTestUtil extends TestUtil {
  StoreRepositoryTestUtil(Dio dio) : super(dio);

  Response handleAddRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case add store':
        return Response(data: 'Error case add content', statusCode: 404);
      case 'Create store':
        return Response(data: {
          'store_id': 2,
          'name': 'Ikea',
        }, statusCode: 201);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleFetchAllRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch all':
        return Response(data: 'Error case fetch all', statusCode: 404);
      case 'Add content':
        Response response = Response(data: createStoreObjects(123), statusCode: 200);
        return response;
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  List<Object> createStoreObjects(int amount) {
    List<Object> stores = List();

    for (int i = 0; i < amount; i++) {
      stores.add({
        'store_id': i,
        'name': 'Ikea No. $i',
      });
    }

    return stores;
  }

}
