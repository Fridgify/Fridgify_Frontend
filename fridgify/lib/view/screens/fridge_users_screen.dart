import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/user_controller.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/error_handler.dart';
import 'package:fridgify/utils/permission_helper.dart';

class UsersPage extends StatefulWidget {
  final Map<User, Permissions> users;
  final Fridge fridge;

  UsersPage(this.users, this.fridge);

  @override
  _UsersPageState createState() => _UsersPageState(this.users, this.fridge);
}

class _UsersPageState extends State<UsersPage> {
  final Map<User, Permissions> users;
  final Fridge fridge;
  final UserService _userService = UserService();
  UserController _controller;
  Permissions mainPerm = Permissions.user;
  ErrorHandler _errorHandler = ErrorHandler();

  _UsersPageState(this.users, this.fridge) {
    this._controller = UserController(this.fridge, this.users, setState);
  }


  @override
  Widget build(BuildContext context) {
    _errorHandler.setContext(context);
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Fridgify"),
        ),
        body: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: this.users.length,
          itemBuilder: (context, index) {
            var u = this.users.keys.toList()[index];

            if (u.username == this._userService.get().username) {
              mainPerm = this.users[u];
              //return SizedBox(height: 0, width: 0,);
            }
            return ListTile(
                onTap: () => _controller.userTapped(_userService.get(), u, mainPerm, this.users[u], context),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(u.name),
                    Text(this.users[u].value()),
                  ],
                ));
          },
        ));
  }
}
