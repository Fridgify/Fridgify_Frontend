import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:fridgify/controller/content.controller.dart';
import 'package:fridgify/utils/fridges.dart';
import 'package:fridgify/view/screens/content.view.dart';

import '../../../config.dart';

class FridgeOverviewButton extends StatefulWidget {
  Fridges fridge;
  FridgeOverviewButton(Fridges f) {
    this.fridge = f;
  }

  @override
  FridgeOverviewButtonState createState() {
    return FridgeOverviewButtonState(this.fridge);
  }
}


// Create a corresponding State class.
// This class holds data related to the form.
class FridgeOverviewButtonState extends State<FridgeOverviewButton> {
  Fridges fridge;
  FridgeOverviewButtonState(Fridges f) {
    this.fridge = f;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: new Key("fridgeBtn"),
      onTap: () async {
        Config.logger.i("Auth ${this.fridge.auth}");
        ContentController c = ContentController(this.fridge.auth, this.fridge.id);
        List<Widget> con =  await c.getContent();
        Navigator.push(context, MaterialPageRoute(builder: (context) => ContentView(this.fridge.auth, this.fridge.id, con)));

      },
      child: Container(
        color: Colors.white,
        child: Center(
        child: Column(
        children: <Widget>[
            Text(this.fridge.name),
            Text(this.fridge.description),
            Text(this.fridge.content),
          ],
        ),
      ),
      ),
    );
  }

}