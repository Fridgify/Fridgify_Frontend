import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/view/screens/content_menu_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:logger/logger.dart';

class LoginController {
  TextEditingController textInputControllerUser = TextEditingController();
  TextEditingController textInputControllerPass = TextEditingController();

  AuthenticationService _authService;

  Logger logger = Logger();

  Future<void> login(BuildContext context, GlobalKey<FormState> key) async {
    _authService = AuthenticationService.login(
        textInputControllerUser.text, textInputControllerPass.text);

    if (!key.currentState.validate()) {
      return;
    }

    Loader.showLoadingDialog(context);

    try {
      await _authService.login();
      await _authService.fetchApiToken();
    } catch (exception) {
      logger.e("LoginController => FAILED TO LOG IN ${exception.toString()}");
      if (exception is FailedToFetchClientTokenException) {
        Navigator.of(context, rootNavigator: true).pop();
        return Popups.errorPopup(context, exception.errMsg());
      }
    }

    try {
      await _authService.initiateRepositories();
    }
    catch(exception) {

      Navigator.of(context, rootNavigator: true).pop();
      return Popups.errorPopup(context, exception.errMsg());
    }

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ContentMenuPage()));
  }
}
