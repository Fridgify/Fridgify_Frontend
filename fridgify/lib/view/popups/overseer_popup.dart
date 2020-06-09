import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/user_controller.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/utils/permission_helper.dart';

class OverseerPopUp extends StatefulWidget {
  final User target;
  final Permissions perm;
  final Fridge fridge;
  final UserController _controller;


  OverseerPopUp(this._controller, this.target, this.perm, this.fridge);

  @override
  _OverseerPopUpState createState() =>
      _OverseerPopUpState(this._controller, this.target, this.perm, this.fridge);
}

class _OverseerPopUpState extends State<OverseerPopUp> {
  User target;
  List<User> users;
  Permissions perm;
  Fridge fridge;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserController _controller;

  _OverseerPopUpState(this._controller, this.target, this.perm, this.fridge);


  @override
  Widget build(BuildContext context) {
    return perm == Permissions.user ? AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Manage User', style: style),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            RaisedButton(
              onPressed: () async => _controller.managePermissionAsOverseer(target, context),
              child: Text('Add as Overseer'),
              color: Colors.purple,
              textColor: Colors.white,
            ),
            RaisedButton(
              onPressed: () async => _controller.removeUser(target, context),
              child: Text('Kick User'),
              color: Colors.purple,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    ) : null;
  }
}
