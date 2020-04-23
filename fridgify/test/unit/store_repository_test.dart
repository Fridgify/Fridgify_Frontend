import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/model/store.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  StoreRepository storeRepository;
  StoreRepositoryTestUtil testUtil;
  MockClient mockClient;
  Store store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    testUtil = StoreRepositoryTestUtil();
    store = Store(storeId: 2, name: 'Ikea');

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

    storeRepository = StoreRepository(mockClient);
  });

  group('add', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case add store');

      expect(() async => completion(await storeRepository.add(store)),
          throwsA(predicate((error) => error is FailedToAddContentException)));
    });

    test('creates successfully', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Create store');

      expect(Future.value(2), completion(await storeRepository.add(store)));
      expect(true, storeRepository.stores.containsKey(2));
    });
    
  });

  group('fetchAll', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case fetch all');

      expect(
              () async => completion(await storeRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('adds all of the returned content', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Add content');

      var content = await storeRepository.fetchAll();

      // Should have 66 entries
      for (int i = 0; i < 123; i++) {
        expect(true, storeRepository.stores.containsKey(i));
      }
    });
  });

}

class StoreRepositoryTestUtil {
  StoreRepositoryTestUtil();


  Response handleGETRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case fetch all':
        return Response('Error case fetch all', 404);
      case 'Add content':
        return Response(json.encode(createStoreObjects(123)), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handlePOSTRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case add store':
        return Response('Error case add content', 404);
      case 'Create store':
        return Response(json.encode({
          'store_id': 2,
          'name': 'Ikea',
        }), 201);
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
        return Response('', 200);
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
