import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';

void main() async {
  AuthenticationService authService;
  Dio mockDio;
  ResponseHandlers handler;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences
        .setString('clientToken', 'Test token');
    mockDio = new Dio();
    handler = ResponseHandlers(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {

    switch (request.extra['testCase']) {
      case "/register/":
        return handler.handleRegisterRequest(request);
      case '/token/':
        return handler.handleFetchApiTokenRequest(request);
      case 'Validate token':
        return handler.handleValidateTokenRequest(request);
      default:
        return Response(data: 'Not implemented', statusCode: 201);
    }
    }));

    authService = AuthenticationService(mockDio);
    authService.user = User.newUser(
        username: 'Mr. Mock',
        password: 'secret',
        name: 'Dieter',
        surname: 'Mock',
        email: 'dieter.mock@miau.de',
        birthDate: '01.01.1969');
  });

  group('Validate Token', () {
    setUp(() {
      handler.setTestCase('Validate token');
    });

    test('doesnt find a cached token', () async {
      await Repository.sharedPreferences.remove('clientToken');

      expect(
          () async => completion(await authService.validateToken()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));
      await Repository.sharedPreferences
          .setString('clientToken', 'Test token');
    });

    test('successfully validates the cached token', () async {
      handler.setId('Token valid');

      expect(Future.value(true), completion(await authService.validateToken()));
    });

    test('unsuccessfully validates the cached token', () async {
      handler.setId('Token invalid');

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
  Dio mockDio;
  ResponseHandlers(Dio dio) {
    this.mockDio = dio;
  }

  void setDio(Dio dio) {
    this.mockDio = dio;
  }

  void setId(String id) {
    mockDio.options.extra.update('id', (value) => id);
  }

  void setTestCase(String testCase) {
    if(!mockDio.options.extra.containsKey('testCase')) {
      mockDio.options.extra.putIfAbsent('testCase', () => testCase);
    } else {
      mockDio.options.extra.update('testCase', (value) => testCase);
    }
  }

  Response handleRegisterRequest(RequestOptions request) {
    return Response(data: 'No register', statusCode: 402);
  }

  Response handleValidateTokenRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Token valid':
        return Response(data: {'token': 'Api token'}, statusCode: 200);
      case 'Token invalid':
        return Response(data: 'invalid token', statusCode: 401);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }

    var name = json.decode(request.data)['username'];

    if (name == 'error') {
      return Response(data: {'detail': 'Error. Login failed'}, statusCode: 401);
    }
    return Response(data: {'token': 'Api token'}, statusCode: 200);
  }

  Response handleFetchApiTokenRequest(RequestOptions request) {
    switch (request.headers.remove('Authorization')) {
      case 'valid token':
        final responseBody = {
          'token': 'Api token',
          'validation_time': 42069,
        };
        return Response(data: responseBody, statusCode: 201);
      case 'Other than 201':
        return Response(data: 'Other than 201', statusCode: 404);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }
}
