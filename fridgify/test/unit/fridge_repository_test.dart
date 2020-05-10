import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_fridges_exception.dart';
import 'package:fridgify/model/fridge.dart';
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
        fridgeId: 69, name: 'Test fridge');
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
      );

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

  group('getFridgeMembers', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case get fridge members');

      expect(
          () async =>
              completion(await fridgeRepository.getFridgeMembers(fridge)),
          throwsA(
              predicate((error) => error is FailedToFetchFridgesException)));
    });

    test('returns all members', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Return member');

      var members = await fridgeRepository.getFridgeMembers(fridge);

      for (int i = 0; i < members.length; i++) {
        expect(
            'username: Mr. Mock No.$i, password: , name: Dieter No.$i, surname: Mock No.$i, email: dieter.mockNo.$i@gmail.de, birthDate: 01.01.1969',
            members[i].toString());
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
        Response response = Response(json.encode(createFridgeObjects(13)), 200);
        Repository.sharedPreferences.setString('apiToken', 'Return member in fetch all');
        return response;
      case 'Error case get fridge members':
        return Response('Error case get fridge members', 404);
      case 'Return member':
        return Response(json.encode(createMemberObjects(13)), 200);
      case 'Return member in fetch all':
        Response response = Response(json.encode(createMemberObjects(13)), 200);
        Repository.sharedPreferences.setString('apiToken', 'Add content in fetch all');
        return response;
      case 'Add content in fetch all':
        return Response(json.encode([]), 200);
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
              'name': 'Test fridge'
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

  List<Object> createMemberObjects(int amount) {
    List<Object> member = List();

    for (int i = 0; i < amount; i++) {
      member.add({
        'username': 'Mr. Mock No.$i',
        'name': 'Dieter No.$i',
        'surname': 'Mock No.$i',
        'email': 'dieter.mockNo.$i@gmail.de',
        'birth_date': '01.01.1969'
      });
    }
    return member;
  }

  List<Object> createFridgeObjects(int amount) {
    List<Object> fridges = List();

    for (int i = 0; i < amount; i++) {
      fridges.add({
        'id': i,
        'name': 'Fridge No. $i',
        'content': {
          'total': i + 120,
          'fresh': i + 52,
          'dueSoon': i + 51,
          'overDue': i,
        }
      });
    }

    return fridges;
  }
}
