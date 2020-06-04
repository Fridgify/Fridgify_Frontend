import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_qr_exception.dart';
import 'package:fridgify/exception/failed_to_patch_user_exception.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';
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
        case "Check username email":
          return testUtil.handleCheckUsernameEmailRequest(request);
        case 'Fetch user':
          return testUtil.handleFetchUserRequest(request);
        case 'Update':
          return testUtil.handleUpdateRequest(request);
        case 'Kick user':
          return testUtil.handleKickUserRequest(request);
        case 'Fetch deep link':
          return testUtil.handleFetchDeepLinkRequest(request);
        case 'Patch user':
          return testUtil.handlePatchUserRequest(request);
        case 'Register notification token':
          return testUtil.handleRegisterNotificationTokenRequest(request);
        default:
          return Response(data: 'Not implemented', statusCode: 201);
      }
    }));

    userService = UserService(mockDio);
  });

  group('patch user', () {
    setUp(() {
      testUtil.setTestCase('Patch user');
    });

    test('throws an error', () async {
      testUtil.setId('Error case patch user');

      expect(
          () async => completion(await userService.patchUser(
              Fridge.create(fridgeId: 1, name: 'awdawd'),
              User.loginUser(username: 'asd', password: '123456'),
              2)),
          throwsA(predicate((error) => error is FailedToPatchUserException)));
    });

    test('returns new role', () async {
      testUtil.setId('Return new role');

      expect(
          Future.value('Fridge Owner'),
          completion(await userService.patchUser(
              Fridge.create(fridgeId: 1, name: 'awdawd'),
              User.loginUser(username: 'asd', password: '123456'),
              2)));
    });
  });

  group('registerNotificationToken', () {
    setUp(() {
      testUtil.setTestCase('Register notification token');
    });

    test('throws an error', () async {
      testUtil.setId('Error case register notification token');
      Repository.sharedPreferences.remove('notification');

      expect(
          () async =>
              completion(await userService.registerNotificationToken('token')),
          throwsA(predicate((error) => error is FailedToFetchQrException)));
    });

    test('register notification', () async {
      testUtil.setId('Register notification');

      expect(Future.value(true),
          completion(await userService.registerNotificationToken('token')));
    });

    test('has token already saved', () async {
      Repository.sharedPreferences.setBool('notification', true);

      expect(Future.value(true),
          completion(await userService.registerNotificationToken('token')));
    });
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

  group('fetchDeepLink', () {
    setUp(() {
      testUtil.setTestCase('Fetch deep link');
    });

    test('throws an error', () async {
      testUtil.setId('Error case fetch deep link');

      expect(
          () async => completion(await userService
              .fetchDeepLink(Fridge.create(name: 'test', fridgeId: 12))),
          throwsA(predicate((error) => error is FailedToFetchQrException)));
    });

    test('gets the link', () async {
      testUtil.setId('Return link');

      expect(
          Future.value('link 123'),
          completion(
            await userService.fetchDeepLink(Fridge.create(name: 'Test')),
          ));
    });
  });

  group('kickUser', () {
    setUp(() {
      testUtil.setTestCase('Kick user');
    });

    test('throws an error', () async {
      testUtil.setId('Error case kick user');

      expect(
          () async => completion(await userService.kickUser(
              Fridge.create(name: 'test', fridgeId: 12),
              User.newUser(
                  username: 'adadsoladn',
                  password: 'asdandan',
                  name: 'Dieter',
                  surname: 'Dieter',
                  email: 'dieter.dieter@gmail.com',
                  birthDate: "2020-01-01"))),
          throwsA(predicate((error) => error is FailedToPatchUserException)));
    });

    test('removes the user', () async {
      testUtil.setId('Remove user');

      expect(
        Future.value(true),
        completion(await userService.kickUser(
            Fridge.create(name: 'Test'),
            User.newUser(
                username: 'adadsoladn',
                password: 'asdandan',
                name: 'Dieter',
                surname: 'Dieter',
                email: 'dieter.dieter@gmail.com',
                birthDate: "2020-01-01"))),
      );
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

  Response handleFetchDeepLinkRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case fetch deep link':
        return Response(data: 'Error case fetch deep link', statusCode: 404);
      case 'Return link':
        return Response(data: {'dynamic_link': "link 123"}, statusCode: 201);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleRegisterNotificationTokenRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case register notification token':
        return Response(
            data: 'Error case register notification link', statusCode: 404);
      case 'Register notification':
        return Response(statusCode: 201);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handlePatchUserRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case patch':
        return Response(data: 'Error case patch', statusCode: 404);
      case 'Return new role':
        return Response(data: {
          'role': 'Fridge Owner',
          'user': {
            'user_id': 2,
            'username': 'testUser',
            'name': 'User',
            'surname': 'test',
            'email': 'test@test.de',
            'birth_date': '01.01.1969',
          }
        }, statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleKickUserRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case kick user':
        return Response(data: 'Error case kick user', statusCode: 404);
      case 'Remove user':
        return Response(data: 'Removed', statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleCheckUsernameEmailRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'All unique':
        return Response(data: {'detail': 'No duplicates'}, statusCode: 200);
      case 'Email not unique':
        return Response(data: {'email': 'test@email.com'}, statusCode: 409);
      case 'Username not unique':
        return Response(data: {'username': 'Hank'}, statusCode: 409);
      case 'Nothing unique':
        return Response(
            data: {'email': 'test@email.com', 'username': 'Hank'},
            statusCode: 409);
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
