import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

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
    _cache.initCache();
    return _cache;
  }

  RequestCache._internal();

  void initCache() async {
    final directory = await _localPath;
    File file = File("$directory/cache.txt");

    logger.i('Read cache from $directory/cache.txt');

    List<dynamic> content = jsonDecode(await file.readAsString());
    content.forEach((element) {
      Response response = Response(data: element['value']['data'], statusCode: element['value']['code']);
      _responseStorage.putIfAbsent(element['key'], () => response);
    });
  }

  void saveToFile() async {
    final directory = await _localPath;
    File file = File("$directory/cache.txt");

    List<Map<String, dynamic>> data = [];
    _responseStorage.forEach((key, value) {
      data.add({
        'key': key,
        'value': {
          'data': value.data,
          'code': value.statusCode
        }
      });
    });
    file.writeAsString(json.encode(data));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

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
    saveToFile();
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