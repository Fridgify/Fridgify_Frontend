
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
          content.add(FridgeContentAddButton(Content.withId(i["item_id"], i["item__name"], i["store"], i["description"], i["amount"], i["unit"], i[""], i["expiration_date"])))
      }

    print(await model.getContent(this.auth.apiToken, this.id));
  }
}