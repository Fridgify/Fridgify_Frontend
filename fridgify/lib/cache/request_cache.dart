import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

class RequestCache {
  static final RequestCache _cache = RequestCache._internal();

  SplayTreeMap<String, Response> _responseStorage = SplayTreeMap();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectivityStatus;

  Logger logger = Logger();

  factory RequestCache() {
    _cache.initConnectivity();
    _cache._connectivitySubscription = _cache._connectivity.onConnectivityChanged.listen(_cache._setConnectionStatus);

    return _cache;
  }

  RequestCache._internal();

  Response cached(RequestOptions request) {
    if(_connectivityStatus != ConnectivityResult.none) {
      return null;
    }

    String key = '${request.method}:${request.path}:${request.data.toString()}';
    if(_responseStorage.containsKey(key)) {
      logger.i("Request cached. Use response from cache.");
      return _responseStorage[key];
    }
    return null;
  }

  void cache(Response response) {
    String key = "${response.request.method}:${response.request.path}:${response.request.data.toString()}";
    if(!_responseStorage.containsKey(key)) {
      _responseStorage.putIfAbsent(key, () => response);
    } else {
      _responseStorage.update(key, (value) => response);
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    return _setConnectionStatus(result);
  }

  void _setConnectionStatus(ConnectivityResult result) {
    logger.i('Connectivity changed. New connection type is $result');
    this._connectivityStatus = result;
  }

}