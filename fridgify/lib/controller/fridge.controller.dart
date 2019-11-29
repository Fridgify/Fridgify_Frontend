import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fridgify/model/fridge.model.dart';
import 'package:fridgify/utils/fridges.dart';
import 'package:fridgify/view/widgets/buttons/fridge_overview_add_button.dart';
import 'package:fridgify/view/widgets/buttons/fridge_overview_button.dart';
import '../config.dart';
import 'auth.controller.dart';

class Fridge {
  FridgeModel model;
  String token;
  Auth auth;


  Fridge(Auth auth) {
    auth.setApiToken();
    this.auth = auth;
    this.model = FridgeModel(auth.clientToken);
  }

  Future<List<Widget>> fetchFridgesOverview() async {
    var fridges = jsonDecode(await model.fetchFridges())["fridges"];
    var frames = List<Widget>();
    Config.logger.i("Creating Fridge Overviews with ${frames.length}");

    for(var f in fridges)
      frames.add(FridgeOverviewButton(Fridges(f["id"], f["name"], f["description"], f["content"])));

    frames.add(FridgeOverviewAddButton(this));
    return frames;
  }

  Future<void> createFridge(String name, String desc) async {
    try{
      await model.addFridge(name, desc);
    } catch(e) {
      print(e);
    }
  }
}