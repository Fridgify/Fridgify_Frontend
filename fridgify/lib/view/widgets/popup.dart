import 'package:flutter/material.dart';

class Popups {
  static Future<void> errorPopup(BuildContext context, String msg) async {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: Text('Error', style: style),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
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
      },
    );
  }
}