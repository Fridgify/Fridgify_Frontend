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
}