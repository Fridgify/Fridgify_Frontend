import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/repository.dart';
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
  ContentRepository contentRepository;
  ContentRepositoryTestUtil testUtil;
  MockClient mockClient;
  Content content;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    testUtil = ContentRepositoryTestUtil();
    content = Content.create(
      expirationDate: DateTime.now().toIso8601String(),
      amount: 13,
      unit: 'stk',
      item: Item(
          itemId: 45,
          barcode: 'adw',
          name: 'Human heart',
          description: 'Fresh',
          store: Store.create(name: 'Ikea')),
    );

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

    contentRepository = ContentRepository(
        Repository.sharedPreferences,
        Fridge.create(fridgeId: 42, name: 'Test fridge', description: '132'),
        mockClient);
  });

  group('add', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case add content');

      expect(() async => completion(await contentRepository.add(content)),
          throwsA(predicate((error) => error is FailedToAddContentException)));
    });

    test('creates successfully', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Create');

      expect(
          Future.value(42), completion(await contentRepository.add(content)));
    });

    test('sets the current date', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Set date');

      var id = await contentRepository.add(content);
      var body = testUtil.body;
      var time = DateTime.now();

      expect(body['buy_date'], '${time.year}-${time.month}-${time.day}');
    });
  });

  group('delete', () {
    test('doesnt delete', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Doesnt delete');

      expect(
          Future.value(false), completion(await contentRepository.delete(13)));
    });

    test('deletes successfully', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Delete');

      contentRepository.contents[66] = Content.create(
        expirationDate: DateTime.now().toIso8601String(),
        amount: 13,
        unit: 'stk',
        item: Item(
            itemId: 66,
            barcode: 'adw',
            name: 'Human heart',
            description: 'Fresh',
            store: Store.create(name: 'Ikea')),
      );

      expect(
          Future.value(true), completion(await contentRepository.delete(66)));
      expect(false, contentRepository.contents.containsKey(66));
    });
  });

  group('fetchAll', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case fetch all');

      expect(
          () async => completion(await contentRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('adds all of the returned content', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Add content');

      testUtil.setUpItems(contentRepository, 66);
      var content = await contentRepository.fetchAll();

      // Should have 66 entries
      for (int i = 0; i < 66; i++) {
        expect(true, contentRepository.contents.containsKey(i));
      }
    });
  });

  group('update', () {
    test('throws an error', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'Error case update content');

      expect(
          () async => completion(
              await contentRepository.update(content, 'Human brains', 'name')),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('updates successfully', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Update');
      var newContent =
          await contentRepository.update(content, 'Human brains', 'name');

      expect('Human brains', newContent.item.name);
    });
  });
}

class ContentRepositoryTestUtil {
  ContentRepositoryTestUtil();

  Map body;

  Response handleGETRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
      case 'Error case fetch all':
        return Response('Error case fetch all', 404);
      case 'Add content':
        return Response(json.encode(createContentObjects(66)), 200);
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

  List<Object> createContentObjects(int amount) {
    List<Object> content = List();

    for (int i = 0; i < amount; i++) {
      content.add({
        'expirationDate': DateTime.now().toIso8601String(),
        'amount': 13,
        'unit': 'stk',
        'item_id': i,
      });
    }

    return content;
  }

  void setUpItems(ContentRepository contentRepository, int amount) {
    for (int i = 0; i < amount; i++) {
      contentRepository.itemRepository.items.putIfAbsent(
          i,
          () => Item(
              itemId: i,
              barcode: 'adw',
              name: 'Human heart',
              description: 'Fresh',
              store: Store.create(name: 'Ikea')));
    }
  }
}
