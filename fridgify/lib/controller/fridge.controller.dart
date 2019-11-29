import 'dart:convert';

import 'package:fridgify/model/fridge.model.dart';
import 'package:fridgify/utils/fridges.dart';
import 'package:fridgify/view/widgets/fridge_frame.dart';

import '../config.dart';
import 'auth.controller.dart';

class Fridge {
  FridgeModel model;
  String token;


  Fridge(Auth auth) {
    auth.setApiToken();
    this.model = FridgeModel(auth.clientToken);
  }

  Future<List<FridgeFrame>> fetchFridgesOverview() async {
    var fridges = jsonDecode(await model.fetchFridges())["fridges"];
    var frames = List<FridgeFrame>();
    Config.logger.i("Creating Fridge Overviews with ${frames.length}");

    for(var f in fridges)
      frames.add(FridgeFrame(Fridges(f["id"], f["name"], f["description"], f["content"])));

    return frames;
  }
}