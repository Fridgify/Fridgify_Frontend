import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  AuthenticationService authService;
  MockClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();

    mockClient = new MockClient((request) async {
      var handler = ResponseHandlers();
      var endpoint =
          request.url.toString().replaceAll('${Repository.baseURL}auth/', '');

      switch (endpoint) {
        case "/register/":
          return handler.handleRegisterRequest(request);
        case '/token/':
          return handler.handleFetchApiTokenRequest(request);
        case '/login/':
          return handler.handleLoginRequest(request);
        default:
          return Response('Not implemented', 201);
      }
    });

    authService = AuthenticationService(mockClient);
    authService.user = User.newUser(
        username: 'Mr. Mock',
        password: 'secret',
        name: 'Dieter',
        surname: 'Mock',
        email: 'dieter.mock@miau.de',
        birthDate: '01.01.1969');
  });

  group('Validate Token', () {
    test('doesnt find a chached token', () async {
      expect(
          () async => completion(await authService.validateToken()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));
    });

    test('successfully validates the chached token', () async {
      await Repository.sharedPreferences
          .setString('clientToken', 'Token valid');

      expect(Future.value(true), completion(await authService.validateToken()));
    });

    test('unsuccessfully validates the chached token', () async {
      await Repository.sharedPreferences
          .setString('clientToken', 'Token invalid');

      expect(
          Future.value(false), completion(await authService.validateToken()));
    });
  });

  group('Login', () {
    test('gets a return type other than 201', () async {
      authService.user.username = 'error';
      expect(
          () async => completion(await authService.login()),
          throwsA(predicate((error) =>
              error is FailedToFetchClientTokenException &&
              error.err == 'Error. Login failed')));
    });

    test('gets a api token', () async {
      expect(Future.value('Api token'), completion(await authService.login()));
      expect(Future.value('Api token'),
          completion(await Repository.sharedPreferences.get('clientToken')));
    });
  });

  group('Register', () {
    test('gets a return type other than 201', () async {
      expect(
          () async => completion(await authService.register()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));
    });
  });

  group('Logout', () {
    test('should return true', () async {
      await Repository.sharedPreferences.setString('clientToken', 'Test123');
      await Repository.sharedPreferences.setString('apiToken', 'Test123');

      expect(Future.value(true), completion(await authService.logout()));
    });

    test('should delete clientToken and apiToken', () async {
      await Repository.sharedPreferences.setString('clientToken', 'Test123');
      await Repository.sharedPreferences.setString('apiToken', 'Test123');

      await authService.logout();

      expect(Future.value(null),
          completion(await Repository.sharedPreferences.get('apiKey')));
      expect(Future.value(null),
          completion(await Repository.sharedPreferences.get('clientToken')));
    });
  });

  group('Fetch api token', () {
    test('doesnt find a cached token', () async {
      expect(
          () async => completion(await authService.fetchApiToken()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));
    });

    test('gets a return type other than 201', () async {
      await Repository.sharedPreferences
          .setString('clientToken', 'Other than 201');

      expect(
          () async => completion(await authService.fetchApiToken()),
          throwsA(
              predicate((error) => error is FailedToFetchApiTokenException)));
    });

    test('gets a token and sets it', () async {
      await Repository.sharedPreferences
          .setString('clientToken', 'valid token');

      expect(Future.value('Api token'),
          completion(await authService.fetchApiToken()));
      expect(Future.value('Api token'),
          completion(await Repository.sharedPreferences.get('apiToken')));
    });
  });
}

class ResponseHandlers {
  ResponseHandlers();

  Response handleRegisterRequest(Request request) {
    return Response('No register', 402);
  }

  Response handleLoginRequest(Request request) {
    if (request.headers.containsKey('Authorization')) {
      switch (request.headers.remove('Authorization')) {
        case 'Token valid':
          return Response(json.encode({'token': 'Api token'}), 200);
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

  Response handleFetchApiTokenRequest(Request request) {
    switch (request.headers.remove('Authorization')) {
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
}
