import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class RequestCache {
  static final RequestCache _cache = RequestCache._internal();

  SplayTreeMap<String, Response> _responseStorage = SplayTreeMap();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectivityStatus;

  Logger _logger = Logger('RequestCache');

  factory RequestCache() {
    if (_cache._connectivityStatus == null) {
      _cache.initRequestCache();
    }
    return _cache;
  }

  RequestCache._internal();

  void initRequestCache() {
    _cache.initConnectivity();
    _cache._connectivitySubscription = _cache
        ._connectivity.onConnectivityChanged
        .listen(_cache._setConnectionStatus);
    _cache.loadCache();
  }

  void loadCache() async {
    final directory = await _localPath;
    File file = File("$directory/cache.txt");

    _logger.i('Read cache from $directory/cache.txt');

    if (!await file.exists()) {
      return;
    }

    try {
      List<dynamic> content = jsonDecode(await file.readAsString());
      content.forEach((element) {
        if (!outdated(element['date'])) {
          Response response = Response(
              extra: new Map<String, dynamic>(),
              data: element['value']['data'],
              statusCode: element['value']['code']);
          response.extra.putIfAbsent('date', () => element['date']);
          _responseStorage.putIfAbsent(element['key'], () => response);
        }
      });
    } catch (e) {
      logger.e(e.toString());
    }
  }

  bool outdated(String date) {
    List<String> parts = date.split(':');
    DateTime now = DateTime.now();
    DateTime savedDate =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    Duration difference = now.difference(savedDate);
    return difference.inDays > 3;
  }

  void saveToFile() async {
    final directory = await _localPath;
    File file = File("$directory/cache.txt");

    List<Map<String, dynamic>> data = [];
    _responseStorage.forEach((key, value) {
      DateTime now = new DateTime.now();
      data.add({
        'date': value.extra.containsKey('date')
            ? value.extra['date']
            : '${now.year}:${now.month}:${now.day}',
        'key': key,
        'value': {'data': value.data, 'code': value.statusCode}
      });
    });
    file.writeAsString(json.encode(data));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Response cached(RequestOptions request) {
    if (_connectivityStatus != ConnectivityResult.none) {
      return null;
    }

    String key = '${request.method}:${request.path}:${request.data.toString()}';
    if (_responseStorage.containsKey(key)) {
      _logger.i("Request cached. Use response from cache.");
      return _responseStorage[key];
    }
    return null;
  }

  void cache(Response response) {
    String key =
        "${response.request.method}:${response.request.path}:${response.request.data.toString()}";
    if (!_responseStorage.containsKey(key)) {
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
    _logger.i('Connectivity changed. New connection type is $result');
    this._connectivityStatus = result;
  }
}
