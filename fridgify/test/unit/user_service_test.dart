import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/testing.dart';

void main() async {

  AuthenticationService authService;
  MockClient mockClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();

    mockClient = new MockClient((request) async {
      var handler = ResponseHandlers();

      switch(request.method) {
        case "GET":
          return handler.handleGETRequest(request);
        case 'POST':
          return handler.handlePOSTRequest(request);
        case 'PATCH':
          return handler.handlePATCHRequest(request);
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
        birthDate: '01.01.1969'
    );
  });

  group('Validate Token', () {

    test('doesnt find a chached token', () async {
      expect(() async => completion(await authService.validateToken()), throwsA(predicate((error) => error is FailedToFetchClientTokenException)));
    });

    test('successfully validates the chached token', () async {
      await Repository.sharedPreferences.setString('clientToken', 'Token valid');

      expect(Future.value(true), completion(await authService.validateToken()));
    });

    test('unsuccessfully validates the chached token', () async {
      await Repository.sharedPreferences.setString('clientToken', 'Token invalid');

      expect(Future.value(false), completion(await authService.validateToken()));
    });

  });

}

class ResponseHandlers {

  ResponseHandlers();

  Response handleGETRequest(Request request) {
    return Response('No register', 402);
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

}