import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/testing.dart';

void main() async {

  UserService userService;
  UserServiceTestUtil testUtil;
  MockClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    testUtil = UserServiceTestUtil();

    mockClient = new MockClient((request) async {

      switch(request.method) {
        case "GET":
          return testUtil.handleGETRequest(request);
        case 'POST':
          return testUtil.handlePOSTRequest(request);
        case 'PATCH':
          return testUtil.handlePATCHRequest(request);
        default:
          return Response('Not implemented', 201);
      }
    });

    userService = UserService(mockClient);
  });

  group('fetch user', () {

    test('throws an error', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Error case fetch user');

      expect(() async => completion(await userService.fetchUser()), throwsA(predicate((error) => error is FailedToFetchContentException)));
    });

    test('gets an user', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Return user');

      var user = await userService.fetchUser();
      expect(testUtil.createUser().toString(), user.toString());
    });

  });

}

class UserServiceTestUtil {

  UserServiceTestUtil();

  Response handleGETRequest(Request request) {
    switch(request.headers.remove('Authorization')) {
      case 'Error case fetch user':
        return Response('Error case fetch user', 404);
      case 'Return user':
        return Response(json.encode(createUserObject()), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handlePOSTRequest(Request request) {

    if(request.headers.containsKey('Authorization')) {
      switch(request.headers.remove('Authorization')) {
        case 'Token valid':
          return Response('valid token', 200);
        case 'Token invalid':
          return Response('invalid token', 401);
        default:
          return Response('Not implemented', 500);
      }
    }

    var name = json.decode(request.body)['username'];

    if (name == 'error') {
      return Response(json.encode({'detail': 'Error. Login failed'}), 401);
    }
    return Response(json.encode({'token': 'Api token'}), 200);
  }

  Response handlePATCHRequest(Request request) {
    switch(request.headers.remove('Authorization')){
      case 'valid token':
        final responseBody = {
          'token': 'Api token',
          'validation_time': 42069,
        };
        return Response(json.encode(responseBody), 201);
      case 'Other than 201':
        return Response('Other than 201', 404);
      default:
        return Response('Not implemented', 500);
    }
  }

  User createUser() {
    return User.newUser(
        username: 'Mr. Mock',
        password: 'secret',
        name: 'Dieter',
        surname: 'Mock',
        email: 'dieter.mock@gmail.de',
        birthDate: '01.01.1969'
    );
  }

  Object createUserObject() {
    return {
      'username': 'Mr. Mock',
      'password': 'secret',
      'name': 'Dieter',
      'surname': 'Mock',
      'email': 'dieter.mock@gmail.de',
      'birth_date': '01.01.1969'
    };
  }

}