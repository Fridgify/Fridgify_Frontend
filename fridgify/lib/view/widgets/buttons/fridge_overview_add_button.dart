import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/fridge.controller.dart';
import 'package:fridgify/view/widgets/forms/add_fridge_form.dart';

class FridgeOverviewAddButton extends StatefulWidget {
  Fridge fridge;

  FridgeOverviewAddButton(this.fridge);


  @override
  FridgeOverviewAddButtonState createState() {
    return FridgeOverviewAddButtonState(this.fridge);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class FridgeOverviewAddButtonState extends State<FridgeOverviewAddButton> {
  final _formKey = GlobalKey<FormState>();
  Fridge fridge;

  FridgeOverviewAddButtonState(this.fridge);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AddFridgeForm(this.fridge),
                    ],
                  ),
                ),
              );
            });
      },
      child: Icon(Icons.add),
    );
  }
}
