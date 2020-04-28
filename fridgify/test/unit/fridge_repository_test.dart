import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_fridges_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/model/store.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  FridgeRepository fridgeRepository;
  FridgeRepositoryTestUtil testUtil;
  MockClient mockClient;
  Fridge fridge;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    testUtil = FridgeRepositoryTestUtil();

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

    fridgeRepository = FridgeRepository(mockClient);

    fridge = Fridge.create(
        fridgeId: 69, name: 'Test fridge', description: 'Cool fridge');
  });

  group('add', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case add fridge');

      expect(
          () async => completion(await fridgeRepository.add(fridge)),
          throwsA(
              predicate((error) => error is FailedToCreateNewFridgeException)));
    });

    test('creates successfully', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Create fridge');

      expect(Future.value(69), completion(await fridgeRepository.add(fridge)));
      expect(fridge.name, fridgeRepository.fridges[69].name);
    });
  });

  group('delete', () {
    test('doesnt delete', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Doesnt delete');

      expect(
          Future.value(false), completion(await fridgeRepository.delete(13)));
    });

    test('deletes successfully', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Delete');

      fridgeRepository.fridges[123] = Fridge.create(
          fridgeId: 123,
          name: 'Fridge to delete',
          description: 'I dont feel so good mister Stark');

      expect(
          Future.value(true), completion(await fridgeRepository.delete(123)));
      expect(false, fridgeRepository.fridges.containsKey(66));
    });
  });

  group('fetchAll', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case fetch all');

      expect(
          () async => completion(await fridgeRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchFridgesException)));
    });

    test('adds all of the returned fridges', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Add fridges');

      var content = await fridgeRepository.fetchAll();

      // Should have 13 entries
      for (int i = 0; i < 13; i++) {
        expect(true, fridgeRepository.fridges.containsKey(i));
      }
    });
  });

}

class FridgeRepositoryTestUtil {
  FridgeRepositoryTestUtil();

  Map body;

  Response handleGETRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case fetch all':
        return Response('Error case fetch all', 404);
      case 'Add fridges':
        return Response(json.encode(createFridgeObjects(13)), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handlePOSTRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case add fridge':
        return Response('Error case add fridge', 404);
      case 'Create fridge':
        return Response(
            json.encode({
              'fridge_id': 69,
              'name': 'Test fridge',
              'description': 'Cool fridge'
            }),
            201);
      case 'Set date':
        body = Map.from(json.decode(request.body));
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
        return Response(
            json.encode({
              'id': 45,
              'expiration_date': DateTime.now().toIso8601String(),
              'amount': 13,
              'unit': 'stk',
              'created_at': DateTime.now().toIso8601String(),
              'last_updated': DateTime.now().toIso8601String(),
              'fridge': 42,
              'item': 45
            }),
            200);
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

  List<Object> createFridgeObjects(int amount) {
    List<Object> fridges = List();

    for (int i = 0; i < amount; i++) {
      fridges.add({
        'id': i,
        'name': 'Fridge No. $i',
        'description': 'Cool fridge No. $i',
        'content': {
          'total': i + 120,
          'fresh': i + 52,
          'dueSoon':	i + 51,
          'overDue': i,
        }
      });
    }

    return fridges;
  }

}
