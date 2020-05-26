import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/user_controller.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/utils/permission_helper.dart';

class OwnerPopUp extends StatefulWidget {
  User target;
  Permissions perm;
  Fridge fridge;
  UserController _controller;


  OwnerPopUp(this._controller, this.target, this.perm, this.fridge);

  @override
  _OwnerPopUpState createState() =>
      _OwnerPopUpState(this._controller, this.target, this.perm, this.fridge);
}

class _OwnerPopUpState extends State<OwnerPopUp> {
  User target;
  List<User> users;
  Permissions perm;
  Fridge fridge;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserController _controller;

  _OwnerPopUpState(this._controller, this.target, this.perm, this.fridge);


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Manage User', style: style),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            RaisedButton(
              onPressed: () async => _controller.managePermissionAsOwner(perm, target, context),
              child: perm == Permissions.overseer ? Text('Remove as Overseer') : Text('Add as Overseer'),
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
    );
  }
}
