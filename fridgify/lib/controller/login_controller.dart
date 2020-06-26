import 'package:flutter/material.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/utils/web_helper.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class LoginController {
  TextEditingController textInputControllerUser = TextEditingController();
  TextEditingController textInputControllerPass = TextEditingController();

  AuthenticationService _authService;

  Logger _logger = Logger('LoginController');

  Future<void> login(BuildContext context, GlobalKey<FormState> key) async {

    // Reset last validation
    Validator.userNotUnique = false;
    Validator.mailNotUnique = false;

    _authService = AuthenticationService.login(
        textInputControllerUser.text, textInputControllerPass.text);

    if (!key.currentState.validate()) {
      return;
    }

    Loader.showSimpleLoadingDialog(context);

    try {
      await _authService.login();
      await _authService.fetchApiToken();
    } catch (exception) {
      Navigator.of(context, rootNavigator: true).pop();
      _logger.e("FAILED TO LOG IN", exception: exception.toString(), popup: false);
      Popups.errorPopup(context, 'Failed to login: ${exception.toString()}');
      return;
    }

    try {
      await _authService.initiateRepositories();
    }
    catch(exception) {

      Navigator.of(context, rootNavigator: true).pop();
      return Popups.errorPopup(context, exception.errMsg());
    }

    Navigator.of(context, rootNavigator: true).pop();


    await Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);

  }

  Future<void> launchPrivacy() async {
    WebHelper _webHelper = WebHelper();
    await _webHelper.launchUrl("https://blog.fridgify.com/privacy-policy/");
  }
}
