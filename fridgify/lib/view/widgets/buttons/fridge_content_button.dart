import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/content.controller.dart';
import 'package:fridgify/controller/fridge.controller.dart';
import 'package:fridgify/utils/content.dart';
import 'package:fridgify/view/screens/content.view.dart';
import 'package:fridgify/view/widgets/forms/add_fridge_form.dart';

class FridgeContentButton extends StatefulWidget {
  Content c;

  FridgeContentButton(this.c);


  @override
  FridgeContentButtonState createState() {
    return FridgeContentButtonState(this.c);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class FridgeContentButtonState extends State<FridgeContentButton> {
  final _formKey = GlobalKey<FormState>();
  Content c;

  FridgeContentButtonState(this.c);

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
                      RaisedButton(
                        child: Text("Remove Item"),
                        onPressed: () async {
                          ContentController con = ContentController(c.auth, c.fId);
                          await con.removeContent(c.id);
                          List<Widget> cont = await con.getContent();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ContentView(c.auth, c.fId, cont)));

                        },
                      )
                    ],
                  ),
                ),
              );
            });
      },
      child: Row(
        children: <Widget>[
          Text(c.name),
          Text("${c.amount}"),
          Text(c.unit),
        ],
      )
    );
  }
}
