import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/model/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  ContentRepository contentRepository;
  ContentRepositoryTestUtil testUtil;
  Dio mockDio;
  Content content;
  Repository.isTest = true;


  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences.setString('apiToken', 'Test token');

    mockDio = new Dio();
    testUtil = ContentRepositoryTestUtil(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {
      switch (request.extra['testCase']) {
        case "Add":
          return testUtil.handleAddRequest(request);
        case "Delete":
          return testUtil.handleDeleteRequest(request);
        case 'Fetch all':
          return testUtil.handleFetchAllRequest(request);
        case 'Update':
          return testUtil.handleUpdateRequest(request);
        case 'Withdraw':
          return testUtil.handleWithdrawRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    content = Content.create(
      contentId: "uuid",
      expirationDate: DateTime.now().toIso8601String(),
      count: 42,
      amount: 13,
      unit: 'stk',
      item: Item(
          itemId: 45,
          barcode: 'adw',
          name: 'Human heart',
          store: Store.create(name: 'Ikea')),
    );

    contentRepository = ContentRepository(
        Repository.sharedPreferences,
        Fridge.create(fridgeId: 42, name: 'Test fridge'),
        mockDio);
  });

  group('add', () {
    setUp(() {
      testUtil.setTestCase('Add');
    });

    test('throws an error', () async {
      testUtil.setId('Error case add content');

      expect(() async => completion(await contentRepository.add(content)),
          throwsA(predicate((error) => error is FailedToAddContentException)));
    });

    test('creates successfully', () async {
      testUtil.setId('Create');

      expect(
          Future.value("Added"), completion(await contentRepository.add(content)));
    });

    test('sets the current date', () async {
      testUtil.setId('Set date');

      var id = await contentRepository.add(content);
      var body = testUtil.body;
      var time = DateTime.now();

      expect(body['buy_date'], '${time.year}-${time.month < 10 ? '0${time.month}' : time.month }-${time.day}');
    });
  });

  group('delete', () {
    setUp(() {
      testUtil.setTestCase('Delete');
    });

    test('doesnt delete', () async {
      testUtil.setId('Doesnt delete');

      expect(
          Future.value(false), completion(await contentRepository.delete("13")));
    });

    test('deletes successfully', () async {
      testUtil.setId('Delete');

      contentRepository.contents["uuid1"] = Content.create(
        contentId: "uuid1",
        expirationDate: DateTime.now().toIso8601String(),
        count: 42,
        amount: 13,
        unit: 'stk',
        item: Item(
            itemId: 66,
            barcode: 'adw',
            name: 'Human heart',
            store: Store.create(name: 'Ikea')),
      );

      expect(
          Future.value(true), completion(await contentRepository.delete("uuid1")));
      expect(false, contentRepository.contents.containsKey("uuid1"));
    });
  });

  group('fetchAll', () {
    setUp(() {
      testUtil.setTestCase('Fetch all');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch all');

      expect(
          () async => completion(await contentRepository.fetchAll()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('adds all of the returned content', () async {
      testUtil.setId('Add content');

      testUtil.setUpItems(contentRepository, 66);
      var content = await contentRepository.fetchAll();

      // Should have 66 entries
      for (int i = 0; i < 66; i++) {
        expect(true, contentRepository.contents.containsKey("test_uuid$i"));
      }
    });
  });

  group('group', () {
    setUp(() {
      contentRepository.contents.clear();
      //Creates 9 copies of three individual items
      //Uses modulo 3 to create items with the same name. Use a multiple of
      //three to have the same amount of items in each group
      var content = testUtil.createContent(27);
      content.forEach((entry) {
        contentRepository.contents[entry.contentId] = entry;
      });
    
    });
    
    tearDown(() {
      contentRepository.contents.clear();
    });

    test('groups 3 items', () {
      contentRepository.group('Useless parameter');

      var groupedContent = contentRepository.grouped;

      print((groupedContent));
      expect(groupedContent.length, 3);

      for(int i = 0; i < 3; i++) {
        expect(groupedContent['Item $i'].length, 9);
      }
    });

  });

  group('withdraw', () {
    setUp(() {
      testUtil.setTestCase('Withdraw');
    });

    test('throws an error', () async {
      testUtil.setId('Error case withdraw');

      expect(
              () async => completion(
              await contentRepository.withdraw(content, 2)),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('withdraws successfully', () async {
      testUtil.setId('Withdraw with something left');

      var testContent = Content.create(
        contentId: "uuid123141141",
        expirationDate: DateTime.now().toIso8601String(),
        count: 1,
        amount: 20,
        unit: 'g',
        item: Item(
            itemId: 5165,
            barcode: 'adw',
            name: 'Human heart',
            store: Store.create(name: 'Ikea')),
      );

      Content content = await contentRepository.withdraw(testContent, 10);

      expect(contentRepository.contents.containsKey('uuid123141141'), true);

    });

    test('removes the item', () async {
      testUtil.setId('Withdraw without something left');

      var testContent = Content.create(
        contentId: "uuid123",
        expirationDate: DateTime.now().toIso8601String(),
        count: 1,
        amount: 20,
        unit: 'g',
        item: Item(
            itemId: 51653,
            barcode: 'adw',
            name: 'Human heart',
            store: Store.create(name: 'Ikea')),
      );
      contentRepository.contents[testContent.contentId] = testContent;
      testContent.amount = 0;

      Content content = await contentRepository.withdraw(testContent, 20);

      expect(contentRepository.contents.containsKey('uuid123'), false);

    });
  });

  group('update', () {
    setUp(() {
      testUtil.setTestCase('Update');
    });

    test('throws an error', () async {
      testUtil.setId('Error case update content');

      expect(
          () async => completion(
              await contentRepository.update(content, 'Human brains', 'name')),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('updates successfully', () async {
      testUtil.setId('Update');

      var newContent =
          await contentRepository.update(content, 'Human brains', 'name');

      expect(content.toString(), newContent.toString());
    });
  });
}

class ContentRepositoryTestUtil extends TestUtil {
  ContentRepositoryTestUtil(Dio dio) : super(dio);

  Map body;

  Response handleWithdrawRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case add content':
        return Response(data: 'Error case withdraw', statusCode: 404);
      case 'Withdraw with something left':
        return Response(data: 'Item response that is not used', statusCode: 200);
      case 'Withdraw without something left':
        return Response(data: 'Item response that is not used', statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleAddRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case add content':
        return Response(data: 'Error case add content', statusCode: 404);
      case 'Create':
        return Response(data: [{
          'id': 45,
          'expiration_date': DateTime.now().toIso8601String(),
          'amount': 13,
          'max_amount': 420,
          'unit': 'stk',
          'created_at': DateTime.now().toIso8601String(),
          'last_updated': DateTime.now().toIso8601String(),
          'fridge': 42,
          'item': 45
        }], statusCode: 201);
      case 'Set date':
        body = Map.from(json.decode(request.data));
        return Response(data: [{
          'id': 45,
          'expiration_date': DateTime.now().toIso8601String(),
          'amount': 13,
          'max_amount': 420,
          'unit': 'stk',
          'created_at': DateTime.now().toIso8601String(),
          'last_updated': DateTime.now().toIso8601String(),
          'fridge': 42,
          'item': 45
        }], statusCode: 201);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleDeleteRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Doesnt delete':
        return Response(data: 'Doesnt delete', statusCode: 404);
      case 'Delete':
        return Response(data: '', statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleFetchAllRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch all':
        return Response(data: 'Error case fetch all', statusCode: 404);
      case 'Add content':
        return Response(data: createContentObjects(66), statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleUpdateRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case update content':
        return Response(data: 'Error case update content', statusCode: 404);
      case 'Update':
        return Response(data: {
              'id': 45,
              'expiration_date': DateTime.now().toIso8601String(),
              'amount': 13,
              'unit': 'stk',
              'created_at': DateTime.now().toIso8601String(),
              'last_updated': DateTime.now().toIso8601String(),
              'fridge': 42,
              'item': 45
            },
            statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  List<Content> createContent(int amount) {
    List<Content> content = List();

    for (int i = 0; i < amount; i++) {
      content.add(Content(
          contentId: 'uuid$i',
          expirationDate: '2020-05-10',
          amount: 42,
          maxAmount: 50,
          unit: 'balls',
          fridge: Fridge(
            name: 'asmsdklöa',
            fridgeId: 23,
            content: {}
          ),
          item: Item(
              name: 'Item ${i % 3}',
              barcode: 'abcas${i % 3}',
              itemId: i % 3,
              store: Store(storeId: 2, name: 'Ikea'),
          )
      ));
    }

    return content;
  }

  List<Object> createContentObjects(int amount) {
    List<Object> content = List();

    for (int i = 0; i < amount; i++) {
      content.add({
        'content_id': 'test_uuid$i',
        'expiration_date': "2020-05-10",
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
              store: Store.create(name: 'Ikea')));
    }
  }
}
