import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/utils/fridges.dart';

class FridgeFrame extends StatefulWidget {
  Fridges fridge;
  FridgeFrame(Fridges f) {
    this.fridge = f;
  }

  @override
  FridgeFrameState createState() {
    return FridgeFrameState(this.fridge);
  }
}


// Create a corresponding State class.
// This class holds data related to the form.
class FridgeFrameState extends State<FridgeFrame> {
  Fridges fridge;
  FridgeFrameState(Fridges f) {
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