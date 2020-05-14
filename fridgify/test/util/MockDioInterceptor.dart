import 'package:dio/dio.dart';

class MockDioInterceptor extends Interceptor {

  Function createResponse;

  MockDioInterceptor(Function responseFunction) {
    createResponse = responseFunction;
  }

  @override
  Future onRequest(RequestOptions options) {
    return createResponse(options);
  }

  @override
  Future onError(DioError err) {
    if(err.response.data != null) {
      return Future.value(err.response);
    }
    throw err;
  }
}