
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fridgify/exceptions/failed_to_create_new_fridge_exception.dart';
import 'package:fridgify/exceptions/failed_to_fetch_fridges_exception.dart';
import 'package:http/http.dart';

import '../config.dart';

class FridgeModel {
  String token;

  FridgeModel(String token) {
    this.token = token;
  }
  
  
  Future<String> fetchFridges() async {
    var response = await get(Config.API + Config.FRIDGE, headers: {"Authorization": this.token});
    Config.logger.i("Fetching Fridges: ${response.statusCode}");
    if(response.statusCode >= 400)
      throw new FailedToFetchFridgesException();
    return response.body;
  }

  Future<void> addFridge(String name, String description) async {
    Config.logger.i("Adding fridge with: $name, $description");
    var response = await post(Config.API + Config.CREATE_FRIDGE,
        headers: {"Authorization": this.token},
        body: jsonEncode({
          "name": name,
          "description": description
        })
    );
    Config.logger.i("Created Fridge ${response.body}");
    if(response.statusCode < 400)
      return;
    throw new FailedToCreateNewFridgeException();
  }
}
