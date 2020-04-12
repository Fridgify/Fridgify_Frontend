import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/exception/not_unique_exception.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/screens/content_menu_screen.dart';
import 'package:fridgify/view/widgets/form_elements.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:logger/logger.dart';

class RegisterController {
  TextEditingController textInputControllerUser = TextEditingController();
  TextEditingController textInputControllerPass = TextEditingController();
  TextEditingController textInputControllerRepeatPass = TextEditingController();
  TextEditingController textInputControllerMail = TextEditingController();
  TextEditingController textInputControllerSur = TextEditingController();
  TextEditingController textInputControllerName = TextEditingController();
  TextEditingController textInputControllerDate = TextEditingController();

  List<Widget> interactiveForm = [];

  AuthenticationService _authService;
  UserService _userService = UserService();

  Logger _logger = Logger();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  BuildContext context;

  int _phase = 0;

  RegisterController() {
    this.interactiveForm = [
      FormElements.textField(
          style: this.style,
          obscureText: false,
          controller: textInputControllerUser,
          hintText: "Username",
          validator: Validator.validateUser),
      SizedBox(height: 25.0),
      FormElements.textField(
          style: this.style,
          obscureText: false,
          controller: textInputControllerMail,
          hintText: "Email",
          validator: Validator.validateMail),
    ];
  }

  Future<void> register(BuildContext context) async {
    _authService = AuthenticationService.register(
        textInputControllerUser.text,
        textInputControllerPass.text,
        textInputControllerMail.text,
        textInputControllerSur.text,
        textInputControllerName.text,
        textInputControllerDate.text);

    Loader.showLoadingDialog(context);

    try {
      await _authService.register();
      await _authService.fetchApiToken();
    } catch (exception) {
      _logger
          .e("RegisterController => FAILED TO LOG IN ${exception.toString()}");
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

  Future<bool> validateFirstForm(
      GlobalKey<FormState> key, BuildContext context) async {
    _logger.e("RegisterController => VALIDATING INPUT");

    // Reset last validation
    Validator.userNotUnique = false;
    Validator.mailNotUnique = false;

    if (!key.currentState.validate()) {
      return false;
    }

    Loader.showLoadingDialog(context);

    try {
      await _userService.checkUsernameEmail(
          textInputControllerUser.text, textInputControllerMail.text);
    } catch (exception) {
      if (exception is NotUniqueException) {
        _logger.i(
            'RegisterController => NOT UNIQUE USER: ${exception.user} EMAIL: ${exception.mail}');

        Validator.userNotUnique = exception.user;
        Validator.mailNotUnique = exception.mail;

        key.currentState.validate();
      } else {
        _logger.e('RegisterController => EXCEPTION $exception');
      }
      Navigator.of(context, rootNavigator: true).pop();
      return false;
    }

    _logger.e("RegisterController => UNIQUE");

    Navigator.of(context, rootNavigator: true).pop();
    return true;
  }

  Future<bool> validateSecondForm(
      GlobalKey<FormState> key, BuildContext context) async {
    Validator.doNotMatch =
        textInputControllerPass.text != textInputControllerRepeatPass.text;
    _logger.e(
        "RegisterController => VALIDATING INPUT 2 DO NOT MATCH: ${Validator.doNotMatch}");


    return key.currentState.validate();
  }

  Future<bool> validateThirdForm(GlobalKey<FormState> key) async {
    return key.currentState.validate();
  }

  Future<void> getNextForm(
      GlobalKey<FormState> key, BuildContext context) async {
    if (_phase == 2 && await validateThirdForm(key)) {
      register(context);
    }

    if (_phase == 1 && await validateSecondForm(key, context)) {
      this.interactiveForm = [
        FormElements.textField(
          style: this.style,
          obscureText: false,
          controller: textInputControllerName,
          hintText: "Last Name",
          validator: Validator.validateName,
        ),
        SizedBox(height: 25.0),
        FormElements.textField(
          style: this.style,
          obscureText: false,
          controller: textInputControllerSur,
          hintText: "First Name",
          validator: Validator.validateFirst,
        ),
        SizedBox(height: 25.0),
        FormElements.datePickerText(
          style: this.style,
          obscureText: false,
          controller: textInputControllerDate,
          hintText: "Birth Date",
          context: context,
          validator: Validator.validateDate,
        ),
        SizedBox(height: 25.0),
      ];
      _phase++;
      return;
    }

    if (_phase == 0 && await validateFirstForm(key, context)) {
      this.interactiveForm = [
        FormElements.textField(
          style: this.style,
          obscureText: true,
          controller: textInputControllerPass,
          hintText: "Password",
          validator: Validator.validatePassword,
        ),
        SizedBox(height: 25.0),
        FormElements.textField(
            style: this.style,
            obscureText: true,
            hintText: "Repeat Password",
            validator: Validator.repeatValidatePassword,
            controller: textInputControllerRepeatPass)
      ];
      _phase++;
      return;
    }
  }
}
