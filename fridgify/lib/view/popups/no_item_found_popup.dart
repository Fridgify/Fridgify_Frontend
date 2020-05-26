import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoItemFoundPopUp extends StatefulWidget {


  NoItemFoundPopUp();

  @override
  _NoItemFoundPopUpState createState() =>
      _NoItemFoundPopUpState();
}

class _NoItemFoundPopUpState extends State<NoItemFoundPopUp> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  _NoItemFoundPopUpState();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('No item found!', style: style),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("We couldn't find an item with the barcode, please add the item manually."),
          ],
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          color: Colors.purple,
          child: Text('Okay'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
