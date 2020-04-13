import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/testing.dart';

void main() async {

  AuthenticationService authService;
  MockClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();

    mockClient = new MockClient((request) async {
      switch(request.headers.remove('Authorization')) {
        case 'Api returns no valid token':
          return Response('Api returns no valid token', 404);
        case 'Api returned valid token':
          final responseBody = {
            'token': 'Api token',
            'validation_time': 42069,
          };
          return Response(json.encode(responseBody), 201);
        default:
          return Response('Not implemented', 201);
      }
    });

    authService = AuthenticationService(mockClient);
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

      expect(Future.value(null), completion(await Repository.sharedPreferences.get('apiKey')));
      expect(Future.value(null), completion(await Repository.sharedPreferences.get('clientToken')));
    });
    
  });

  group('fetchApiToken', () {

    test('doesnt find a cached token', () async {
      expect(() async => completion(await authService.fetchApiToken()), throwsA(predicate((error) => error is FailedToFetchClientTokenException)));
    });

    test('gets a return type other than 201', () async {
      await Repository.sharedPreferences.setString('clientToken', 'Api returns no valid token');

      expect(() async => completion(await authService.fetchApiToken()), throwsA(predicate((error) => error is FailedToFetchApiTokenException)));
    });

    test('gets a token and sets it', () async {
      await Repository.sharedPreferences.setString('clientToken', 'Api returned valid token');

      expect(Future.value('Api token'), completion(await authService.fetchApiToken()));
      expect(Future.value('Api token'), completion(await Repository.sharedPreferences.get('apiToken')));
    });

  });

}
