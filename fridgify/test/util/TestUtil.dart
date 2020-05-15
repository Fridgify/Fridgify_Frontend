import 'package:dio/dio.dart';

abstract class TestUtil {
  Dio mockDio;

  TestUtil(Dio dio) {
    this.mockDio = dio;
  }

  void setDio(Dio dio) {
    this.mockDio = dio;
  }

  void setId(String id) {
    mockDio.options.extra.update('id', (value) => id);
  }

  void setTestCase(String testCase) {
    if (!mockDio.options.extra.containsKey('testCase')) {
      mockDio.options.extra.putIfAbsent('testCase', () => testCase);
    } else {
      mockDio.options.extra.update('testCase', (value) => testCase);
    }
  }
}