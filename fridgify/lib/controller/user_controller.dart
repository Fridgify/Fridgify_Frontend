import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/permission_helper.dart';
import 'package:fridgify/view/popups/overseer_popup.dart';
import 'package:fridgify/view/popups/owner_popup.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:logger/logger.dart';

class UserController {
  final Fridge fridge;
  final Function setState;
  Map<User, Permissions> users;
  Logger _logger = Logger();


  UserService _userService = UserService();

  UserController(this.fridge, this.users, this.setState);

  Future<void> userTapped(User host, User target, Permissions hostPerm,
      Permissions targetPerm, BuildContext context) async {
    switch (hostPerm) {
      case Permissions.user:
        break;
      case Permissions.overseer:
        if(targetPerm == Permissions.user)
          return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return OverseerPopUp(this, target, targetPerm, this.fridge);
              });
        break;
      case Permissions.owner:
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return OwnerPopUp(this, target, targetPerm, this.fridge);
            });
    }


  }
  Future<void> removeAdmin(Fridge f, User u) async {
    try {
      await _userService.patchUser(f, u, 2);
      this.users[u] = Permissions.user;
    }
    catch(exception) {
      _logger.e("UserController => REMOVE ADMIN FAILED $exception");
    }
  }

  Future<void> addAdmin(Fridge f, User u) async {
    try {
      await _userService.patchUser(f, u, 1);
      this.users[u] = Permissions.overseer;
    }
    catch(exception) {
      _logger.e("UserController => ADDING ADMIN FAILED $exception");
    }
  }
  Future<void> managePermissionAsOverseer(User target, BuildContext context) async {
    Loader.showSimpleLoadingDialog(context);
    await this.addAdmin(this.fridge, target);
    this.setState(() {});
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }


  Future<void> managePermissionAsOwner(Permissions perm, User target, BuildContext context) async {
    Loader.showSimpleLoadingDialog(context);
    perm == Permissions.overseer ? await this.removeAdmin(this.fridge, target) : await this.addAdmin(this.fridge, target);
    this.setState(() {});
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> removeUser(User target, BuildContext context) async {
    Loader.showSimpleLoadingDialog(context);

    try {
      await _userService.kickUser(this.fridge, target);
      users.remove(target);
    }
    catch(exception) {
      _logger.e("UserController => REMOVING FAILED $exception");
    }

    this.setState(() {});
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
