import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MockDioInterceptor.dart';
import '../util/TestUtil.dart';

void main() async {
  AuthenticationService authService;
  Dio mockDio;
  AuthServiceTestUtil testUtil;
  Repository.isTest = true;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
    await Repository.sharedPreferences.setString('clientToken', 'Test token');

    mockDio = new Dio();
    testUtil = AuthServiceTestUtil(mockDio);
    mockDio.options.extra.putIfAbsent('id', () => 'None');
    mockDio.interceptors.add(MockDioInterceptor((RequestOptions request) async {
      switch (request.extra['testCase']) {
        case "Register":
          return testUtil.handleRegisterRequest(request);
        case 'Fetch api token':
          return testUtil.handleFetchApiTokenRequest(request);
        case 'Validate token':
          return testUtil.handleValidateTokenRequest(request);
        case 'Login':
          return testUtil.handleLoginRequests(request);
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
      testUtil.setTestCase('Validate token');
    });

    test('doesnt find a cached token', () async {
      await Repository.sharedPreferences.remove('clientToken');

      expect(
          () async => completion(await authService.validateToken()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));
      await Repository.sharedPreferences.setString('clientToken', 'Test token');
    });

    test('successfully validates the cached token', () async {
      testUtil.setId('Token valid');

      expect(Future.value(true), completion(await authService.validateToken()));
    });

    test('unsuccessfully validates the cached token', () async {
      testUtil.setId('Token invalid');

      expect(
          Future.value(false), completion(await authService.validateToken()));
    });
  });

  group('Login', () {
    setUp(() {
      testUtil.setTestCase('Login');
    });

    test('gets a return type other than 201', () async {
      testUtil.setId('Return error');

      expect(
          () async => completion(await authService.login()),
          throwsA(predicate((error) =>
              error is FailedToFetchClientTokenException &&
              error.err == 'Error. Login failed')));
    });

    test('gets a api token', () async {
      testUtil.setId('Login successfully');

      expect(Future.value('Api token'), completion(await authService.login()));
      expect(Future.value('Api token'),
          completion(await Repository.sharedPreferences.get('clientToken')));
    });
  });

  group('Register', () {
    setUp(() {
      testUtil.setTestCase('Register');
    });

    test('gets a return type other than 201', () async {
      testUtil.setId('Error case register');

      expect(
          () async => completion(await authService.register()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));
    });

    test('registers', () async {
      testUtil.setId('Register');

      expect(Future.value(null),
          completion(await Repository.sharedPreferences.get('apiKey')));
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
    setUp(() {
      testUtil.setTestCase('Fetch api token');
    });

    test('doesnt find a cached token', () async {
      await Repository.sharedPreferences.remove('clientToken');

      expect(
          () async => completion(await authService.fetchApiToken()),
          throwsA(predicate(
              (error) => error is FailedToFetchClientTokenException)));

      await Repository.sharedPreferences.setString('clientToken', 'Test token');
    });

    test('gets a return type other than 201', () async {
      testUtil.setId('Other than 201');

      expect(
          () async => completion(await authService.fetchApiToken()),
          throwsA(
              predicate((error) => error is FailedToFetchApiTokenException)));
    });

    test('gets a token and sets it', () async {
      testUtil.setId('Valid token');

      expect(Future.value('Api token'),
          completion(await authService.fetchApiToken()));
      expect(Future.value('Api token'),
          completion(await Repository.sharedPreferences.get('apiToken')));
    });
  });
}

class AuthServiceTestUtil extends TestUtil {
  AuthServiceTestUtil(Dio dio) : super(dio);

  Response handleRegisterRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Error case register':
        return Response(data: 'No register', statusCode: 402);
      case 'Register':
        Response response =
            Response(data: {'token': 'Api token'}, statusCode: 201);
        setId('Register - Login successfully');
        return response;
      case 'Register - Login successfully':
        return Response(data: {'token': 'Api token'}, statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
  }

  Response handleLoginRequests(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Return error':
        return Response(
            data: {'detail': 'Error. Login failed'}, statusCode: 401);
      case 'Login successfully':
        return Response(data: {'token': 'Api token'}, statusCode: 200);
      default:
        return Response(data: 'Not implemented', statusCode: 500);
    }
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
  }

  Response handleFetchApiTokenRequest(RequestOptions request) {
    switch (request.extra['id']) {
      case 'Valid token':
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
