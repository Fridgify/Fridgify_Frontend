import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/utils/fridges.dart';

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
    return Container(
      color: Colors.white,
      child: GestureDetector(
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