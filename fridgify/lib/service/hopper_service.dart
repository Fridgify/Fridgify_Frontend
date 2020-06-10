import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:url_launcher/url_launcher.dart';

class HopperService {
  static final String _fetchApiUrl = "${Repository.baseURL}messaging/subscribe?service=2";
  static final String _registerApiUrl = "${Repository.baseURL}messaging/register/";

  Dio dio;

  Logger _logger = Logger('HopperService');

  static final HopperService _hopperService = HopperService._internal();

  factory HopperService([Dio dio]) {
    _hopperService.dio = Repository.getDio(dio);
    return _hopperService;
  }

  HopperService._internal();

  Future<String> _fetchUrl() async {
    var response = await dio.get(_fetchApiUrl, options: Options(
        headers: Repository.getHeaders()));

    _logger.i('FETCHING HOPPER URL: ${response.data}');

    if(response.statusCode == 200) {
      _logger.i('GOT DATA ${response.data}');
      return response.data['subscribe_url'];
    }
    _logger.e('AN ERROR OCCURED WHILE SUBSCRIBING ${response.statusMessage}');
  }

  Future<void> requestToken() async {
    String url = await _fetchUrl();

    if(await canLaunch(url)) {
      await launch(url);
    }
    else {
      _logger.e("FAILED TO LAUNCH URL $url");
    }

  }

  Future<void> registerToken(dynamic id, BuildContext context) async {

    if(Repository.sharedPreferences.containsKey('hopper'))
      return;

    await Repository.sharedPreferences.setBool('hopper', true);

    var response = await dio.post(_registerApiUrl, options: Options(
        headers: Repository.getHeaders()),
        data: jsonEncode({'client_token': id, 'service': 2}));

    _logger.i('SUBBSCRIBING TO HOPPER: ${response.statusCode}');

    if(response.statusCode == 201) {
      _logger.i('SUBSCRIBED ${response.data}');
      Popups.infoPopup(context, 'Hopper', 'Successfully subscribed to Hopper notifications');
      return;
    }

    _logger.e('AN ERROR OCCURED WHILE SUBSCRIBING ${response.statusMessage}');
  }

}