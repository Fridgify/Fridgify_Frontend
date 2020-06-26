import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/hopper_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/view/widgets/popup.dart';

class SettingsController {
  final HopperService _hopperService = HopperService();
  final UserService _userService = UserService();
  final AuthenticationService _authenticationService = AuthenticationService();

  SettingsController();

  Future<void> addHopper(BuildContext context) async {
    if(Repository.sharedPreferences.containsKey('hopper')) {
      Popups.infoPopup(context, 'Hopper', 'Already added notifications');
    }
    else {
      await _hopperService.requestToken();
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    bool deleted = false;
    await Popups.confirmationPopup(context, "Delete User", "Are you sure you would like to delete your User? This cannot be undone!", () async { deleted = await _userService.delete(); });
    if(deleted) {
      if(await _authenticationService.logout())
        await Navigator.of(context).pushReplacementNamed("/startup");
    }
  }
}