import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/user.dart';
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
      expect(testUtil.createUser(1, 'pw')[0].toString(), user.toString());
    });

    test('saves the user in the user service', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Return user');

      var user = await userService.fetchUser();
      expect(testUtil.createUser(1, 'pw')[0].toString(), userService.user.toString());
    });

  });

  group('get users for fridge', () {

    test('throws an error', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Error case fetch user');

      expect(() async => completion(await userService.getUsersForFridge(42)), throwsA(predicate((error) => error is FailedToFetchContentException)));
    });

    test('returns the user list for fridge 42', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Return users for fridge 42');

      var users = await userService.getUsersForFridge(42);
      var testUsers = testUtil.createUser(42, 'nopw');

      for(int i = 0; i < users.length; i++) {
        expect(testUsers[i].toString(), users[i].toString());
      }

      expect(testUsers.length, users.length);

    });

  });

  group('update', () {

    test('throws an error', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Error case fetch user');
      User user = testUtil.createUser(1, 'pw')[0];

      expect(() async => completion(await userService.update(user, 'name', 'Olaf')), throwsA(predicate((error) => error is FailedToFetchContentException)));
    });

    test('updates the attribute', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Update attribute');
      User user = testUtil.createUser(1, 'pw')[0];
      
      User updatedUser = await userService.update(user, 'name', 'Olaf');
      
      expect('Olaf', updatedUser.name);
    });

    test('saves the user in the user service', () async {
      await Repository.sharedPreferences.setString('apiToken', 'Update attribute');
      User user = testUtil.createUser(1, 'pw')[0];

      User updatedUser = await userService.update(user, 'name', 'Olaf');

      expect('Olaf', userService.user.name);
    });

  });

  group('check username email', () {

    
  });



}

class UserServiceTestUtil {

  UserServiceTestUtil();

  Response handleGETRequest(Request request) {
    switch(request.headers.remove('Authorization')) {
      case 'Error case fetch user':
        return Response('Error case fetch user', 404);
      case 'Return user':
        return Response(json.encode(createUserObject(1, 'pw')[0]), 200);
      case 'Return users for fridge 42':
        return Response(json.encode(createUserObject(42, 'nopw')), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  Response handlePOSTRequest(Request request) {
    var username = json.decode(request.body)['username'];

    if(username == 'Not unique') {
      return Response(request.body, 409);
    }

    if(username == 'Unique') {
      return Response('', 200);
    }

    return Response('Not implemented', 500);
  }

  Response handlePATCHRequest(Request request) {
    switch(request.headers.remove('Authorization')){
      case 'Error case fetch user':
        return Response('Error case fetch user', 404);
      case 'Update attribute':
        var user = Map.from(createUserObject(1, 'nopw')[0]);
        var body = Map.from(json.decode(request.body));

        body.forEach((key, value) => {
          user[key] = value
        });

        return Response(json.encode(user), 200);
      default:
        return Response('Not implemented', 500);
    }
  }

  List<User> createUser(int amount, mode) {
    List<User> users = List();

    for(int i = 0; i < amount; i++) {
      switch (mode) {
        case 'pw':
          users.add(User.newUser(
              username: 'Mr. Mock No.$i',
              password: 'secret',
              name: 'Dieter No.$i',
              surname: 'Mock No.$i',
              email: 'dieter.mockNo.$i@gmail.de',
              birthDate: '01.01.1969'
          ));
          break;
        case 'nopw':
          users.add(User.noPassword(
              username: 'Mr. Mock No.$i',
              name: 'Dieter No.$i',
              surname: 'Mock No.$i',
              email: 'dieter.mockNo.$i@gmail.de',
              birthDate: '01.01.1969'
          ));
          break;
      }
    }
    return users;
  }

  List<Object> createUserObject(int amount, mode) {
    List<Object> userObjects = List();

    for(int i = 0; i < amount; i++) {
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