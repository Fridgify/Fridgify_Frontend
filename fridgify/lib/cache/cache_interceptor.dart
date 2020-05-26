import 'package:dio/dio.dart';
import 'package:fridgify/cache/request_cache.dart';

class CacheInterceptor extends Interceptor {

  RequestCache requestCache = RequestCache();

  @override
  Future onRequest(RequestOptions options) {
    var cache = requestCache.cached(options);
    if(cache != null) {
      return Future.value(cache);
    }
    return Future.value(options);
  }

  @override
  Future onError(DioError error) {
    if(error.response != null) {
      requestCache.cache(error.response);
      return Future.value(error.response);
    } else {
      throw error;
    }
  }

  @override
  Future onResponse(Response response) {
    requestCache.cache(response);
    return Future.value(response);
  }
}