
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fridgify/model/content.model.dart';
import 'package:fridgify/utils/content.dart';
import 'package:fridgify/view/widgets/buttons/fridge_content_add_button.dart';
import 'package:fridgify/view/widgets/buttons/fridge_content_button.dart';

import '../config.dart';
import 'auth.controller.dart';

class ContentController {
  Auth auth;
  int id;
  ContentModel model = ContentModel();


  ContentController(this.auth, this.id) {
    Config.logger.i("Content overview for $id with token $auth");
  }

  Future<List<Widget>> getContent() async {
    List<Widget> content = new List();

    for(var i in jsonDecode(await model.getContent(this.auth.apiToken, this.id)))
      {
        Config.logger.i("Adding Content with id ${i["item_id"]}");
          content.add(FridgeContentButton(Content.withId(i["item_id"], i["item__name"], i["description"], i["amount"], i["unit"], i["expiration_date"], this.auth, this.id)));
      }

    content.add(FridgeContentAddButton(this));

    return content;
  }

  Future<void> removeContent(int itId) async {
    Config.logger.i("Removing Content with id: $itId");
    await model.removeContent(this.auth.apiToken, this.id, itId);
  }

  Future<void> addContent(String item, String store, String desc, int amount, String unit, String date) async {
    Content c = Content(item, store, desc, amount, unit, DateTime.now().toString().split(" ")[0], date);
    Config.logger.i("Adding Item ${c.getJson()} to $id");
    await model.addContent(auth.apiToken, this.id, c);
  }
}