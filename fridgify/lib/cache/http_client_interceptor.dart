import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

class HttpClientInterceptor implements InterceptorContract {

  Logger logger = Logger();

  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    return data;
  }
}