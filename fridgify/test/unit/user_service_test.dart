import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  UserService userService;
  UserServiceTestUtil testUtil;
  Dio mockDio;
  Repository.isTest = true;


  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences.setString('apiToken', 'Test token');

    mockDio = new Dio();
    testUtil = UserServiceTestUtil(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {
      switch (request.extra['testCase']) {
        case "Get users for fridge":
          return testUtil.handleGetUsersForFridgeRequest(request);
        case "Check username email":
          return testUtil.handleCheckUsernameEmailRequest(request);
        case 'Fetch user':
          return testUtil.handleFetchUserRequest(request);
        case 'Update':
          return testUtil.handleUpdateRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    userService = UserService(mockDio);
  });

  group('fetch user', () {
    setUp(() {
      testUtil.setTestCase('Fetch user');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch user');

      expect(
          () async => completion(await userService.fetchUser()),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('gets an user', () async {
      testUtil.setId('Return user');

      var user = await userService.fetchUser();
      expect(testUtil.createUser(1, 'pw')[0].toString(), user.toString());
    });

    test('saves the user in the user service', () async {
      testUtil.setId('Return user');

      var user = await userService.fetchUser();
      expect(testUtil.createUser(1, 'pw')[0].toString(),
          userService.user.toString());
    });
  });

  group('get users for fridge', () {
    setUp(() {
      testUtil.setTestCase('Get users for fridge');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch user');

      expect(
          () async => completion(await userService.getUsersForFridge(42)),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('returns the user list for fridge 42', () async {
      testUtil.setId('Return users for fridge 42');

      var users = await userService.getUsersForFridge(42);
      var testUsers = testUtil.createUser(42, 'nopw');

      for (int i = 0; i < users.length; i++) {
        expect(testUsers[i].toString(), users[i].toString());
      }

      expect(testUsers.length, users.length);
    });
  });

  group('update', () {
    setUp(() {
      testUtil.setTestCase('Update');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch user');

      User user = testUtil.createUser(1, 'pw')[0];

      expect(
          () async =>
              completion(await userService.update(user, 'name', 'Olaf')),
          throwsA(
              predicate((error) => error is FailedToFetchContentException)));
    });

    test('updates the attribute', () async {
      testUtil.setId('Update attribute');

      User user = testUtil.createUser(1, 'pw')[0];

      User updatedUser = await userService.update(user, 'name', 'Olaf');

      expect('Olaf', updatedUser.name);
    });

    test('saves the user in the user service', () async {
      testUtil.setId('Update attribute');

      User user = testUtil.createUser(1, 'pw')[0];

      User updatedUser = await userService.update(user, 'name', 'Olaf');

      expect('Olaf', userService.user.name);
    });
  });

  group('check username email', () {
    setUp(() {
      testUtil.setTestCase('Check username email');
    });

    test('name and email are unique', () async {
      testUtil.setId('All unique');

      Map<String, bool> response = await userService.checkUsernameEmail(
      'Dieter', 'dieter.baum@gmail.com');

      expect(false, response['user']);
      expect(false, response['mail']);
    });

    test('email not unique', () async {
      testUtil.setId('Email not unique');

      Map<String, bool> response = await userService.checkUsernameEmail(
          'Dieter', 'dieter.baum@gmail.com');
      print(response);

      expect(false, response['user']);
      expect(true, response['mail']);
    });

    test('username not unique', () async {
      testUtil.setId('Username not unique');

      Map<String, bool> response = await userService.checkUsernameEmail(
          'Dieter', 'dieter.baum@gmail.com');

      expect(true, response['user']);
      expect(false, response['mail']);
    });

    test('name and email are not unique', () async {
      testUtil.setId('Nothing unique');

      Map<String, bool> response = await userService.checkUsernameEmail(
          'Dieter', 'dieter.baum@gmail.com');

      expect(true, response['user']);
      expect(true, response['mail']);
    });
  });
}

class UserServiceTestUtil extends TestUtil {
  UserServiceTestUtil(Dio dio) : super(dio);

  Response handleGetUsersForFridgeRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case add content':
        return Response(data: 'Error case fetch user', statusCode: 404);
      case 'Return users for fridge 42':
        return Response(data: createUserObject(42, 'nopw'), statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleCheckUsernameEmailRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'All unique':
        return Response(data: {
          'detail': 'No duplicates'
        }, statusCode: 200);
      case 'Email not unique':
        return Response(data: { 'email': 'test@email.com'}, statusCode: 409);
      case 'Username not unique':
        return Response(data: { 'username': 'Hank'}, statusCode: 409);
      case 'Nothing unique':
        return Response(data: {
          'email': 'test@email.com',
          'username': 'Hank'
        }, statusCode: 409);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleFetchUserRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch user':
        return Response(data: 'Error case fetch user', statusCode: 404);
      case 'Return user':
        return Response(data: createUserObject(1, 'pw')[0], statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleUpdateRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch user':
        return Response(data: 'Error case fetch user', statusCode: 404);
      case 'Update attribute':
        var user = Map.from(createUserObject(1, 'nopw')[0]);
        var body = Map.from(json.decode(request.data));

        body.forEach((key, value) => {user[key] = value});
        return Response(data: user, statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  List<User> createUser(int amount, mode) {
    List<User> users = List();

    for (int i = 0; i < amount; i++) {
      switch (mode) {
        case 'pw':
          users.add(User.newUser(
              username: 'Mr. Mock No.$i',
              password: 'secret',
              name: 'Dieter No.$i',
              surname: 'Mock No.$i',
              email: 'dieter.mockNo.$i@gmail.de',
              birthDate: '01.01.1969'));
          break;
        case 'nopw':
          users.add(User.noPassword(
              username: 'Mr. Mock No.$i',
              name: 'Dieter No.$i',
              surname: 'Mock No.$i',
              email: 'dieter.mockNo.$i@gmail.de',
              birthDate: '01.01.1969'));
          break;
      }
    }
    return users;
  }

  List<Object> createUserObject(int amount, mode) {
    List<Object> userObjects = List();

    for (int i = 0; i < amount; i++) {
      switch (mode) {
        case 'pw':
          userObjects.add({
            'username': 'Mr. Mock No.$i',
            'password': 'secret',
            'name': 'Dieter No.$i',
            'surname': 'Mock No.$i',
            'email': 'dieter.mockNo.$i@gmail.de',
            'birth_date': '01.01.1969'
          });
          break;
        case 'nopw':
          userObjects.add({
            'username': 'Mr. Mock No.$i',
            'name': 'Dieter No.$i',
            'surname': 'Mock No.$i',
            'email': 'dieter.mockNo.$i@gmail.de',
            'birth_date': '01.01.1969'
          });
          break;
      }
    }

    return userObjects;
  }
}
