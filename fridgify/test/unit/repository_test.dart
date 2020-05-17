import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/exception/failed_to_fetch_content_exception.dart';
import 'package:fridgify/model/store.dart';
import 'package:http/http.dart' show Response, Request;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Repository.isTest = true;


  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Repository.sharedPreferences = await SharedPreferences.getInstance();
  });

  group('Get token', () {

    test('should throw an exeption', () {
      expect(
              () async => completion(await Repository.getToken()),
          throwsA(
              predicate((error) => error is FailedToFetchApiTokenException)));
    });

    test('returns the token', () async {
      await Repository.sharedPreferences
          .setString('apiToken', 'An api token');
      expect('An api token', Repository.getToken());
    });

  });

  group('Get headers', () {

    test('returns headers', () async {
      await Repository.sharedPreferences.setString('apiToken', 'An api token');

      var headers = Repository.getHeaders();
      expect('application/json', headers['Content-Type']);
      expect('An api token', headers['Authorization']);
    });

  });
  
  group('Get dio', () {

    test('returns test dio', () async {
      Dio dio = Dio();
      dio.options.extra.putIfAbsent('test', () => 'Test dio');
      
      Dio returnedDio = Repository.getDio(dio);
      expect('Test dio', returnedDio.options.extra['test']);
    });

  });


}
