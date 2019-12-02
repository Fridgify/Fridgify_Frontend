import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/content.controller.dart';
import 'package:fridgify/controller/fridge.controller.dart';
import 'package:fridgify/view/widgets/forms/add_content_form.dart';
import 'package:fridgify/view/widgets/forms/add_fridge_form.dart';

class FridgeContentAddButton extends StatefulWidget {
  ContentController c;
  FridgeContentAddButton(this.c);


  @override
  FridgeContentAddButtonState createState() {
    return FridgeContentAddButtonState(this.c);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class FridgeContentAddButtonState extends State<FridgeContentAddButton> {
  final _formKey = GlobalKey<FormState>();
  ContentController c;
  FridgeContentAddButtonState(this.c);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      key: new Key("add_content"),
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
                      AddContentForm(this.c),
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
