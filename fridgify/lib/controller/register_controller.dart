import 'package:flutter/material.dart';
import 'package:fridgify/exception/failed_to_fetch_client_token.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/widgets/form_elements.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class RegisterController {
  TextEditingController textInputControllerUser = TextEditingController();
  TextEditingController textInputControllerPass = TextEditingController();
  TextEditingController textInputControllerRepeatPass = TextEditingController();
  TextEditingController textInputControllerMail = TextEditingController();
  TextEditingController textInputControllerSur = TextEditingController();
  TextEditingController textInputControllerName = TextEditingController();
  TextEditingController textInputControllerDate = TextEditingController();

  FocusNode focusNodePas = FocusNode();
  FocusNode focusNodeFirst = FocusNode();

  List<Widget> interactiveForm = [];

  AuthenticationService _authService;
  UserService _userService = UserService();

  Logger _logger = Logger('RegisterController');

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  BuildContext context;

  int _phase = 0;

  RegisterController() {
    this.interactiveForm = [
      FormTextField(
          key: Key('registerUsername'),
          style: this.style,
          obscureText: false,
          controller: textInputControllerUser,
          hintText: "Username",
          validator: Validator.validateUser),
      SizedBox(height: 25.0),
      FormTextField(
          key: Key('email'),
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
        textInputControllerSur.text,
        textInputControllerName.text,
        textInputControllerMail.text,
        textInputControllerDate.text);

    Loader.showSimpleLoadingDialog(context);

    try {
      await _authService.register();
      await _authService.fetchApiToken();
    } catch (exception) {
      _logger
          .e("FAILED TO LOG IN ${exception.toString()}");
      if (exception is FailedToFetchClientTokenException) {
        Navigator.of(context, rootNavigator: true).pop();
        return Popups.errorPopup(context, exception.errMsg());
      }
    }

    try {
      await _authService.initiateRepositories();
    } catch (exception) {
      Navigator.of(context, rootNavigator: true).pop();
      return Popups.errorPopup(context, exception.errMsg());
    }

    Navigator.of(context, rootNavigator: true).pop();

    await Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
  }

  Future<bool> validateFirstForm(
      GlobalKey<FormState> key, BuildContext context) async {
    _logger.e("VALIDATING INPUT");

    // Reset last validation
    Validator.userNotUnique = false;
    Validator.mailNotUnique = false;

    if (!key.currentState.validate()) {
      return false;
    }
    Loader.showSimpleLoadingDialog(context);

    var checks = await _userService.checkUsernameEmail(
        textInputControllerUser.text, textInputControllerMail.text);

    if (checks['user'] || checks['mail']) {
      _logger.i(
          'NOT UNIQUE USER: ${checks['user']} EMAIL: ${checks['mail']}');

      Validator.userNotUnique = checks['user'];
      Validator.mailNotUnique = checks['mail'];

      key.currentState.validate();

      Navigator.of(context, rootNavigator: true).pop();
      return false;
    }

    _logger.e("UNIQUE");

    Navigator.of(context, rootNavigator: true).pop();
    return true;
  }

  Future<bool> validateSecondForm(
      GlobalKey<FormState> key, BuildContext context) async {
    Validator.doNotMatch =
        textInputControllerPass.text != textInputControllerRepeatPass.text;
    _logger.e(
        "VALIDATING INPUT 2 DO NOT MATCH: ${Validator.doNotMatch}");

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
        FormTextField(
          key: Key('firstName'),
          style: this.style,
          obscureText: false,
          controller: textInputControllerSur,
          hintText: "First Name",
          validator: Validator.validateFirst,
        ),
        SizedBox(height: 25.0),
        FormTextField(
          key: Key('lastName'),
          style: this.style,
          obscureText: false,
          controller: textInputControllerName,
          hintText: "Last Name",
          validator: Validator.validateName,
        ),
        SizedBox(height: 25.0),
        DatePickerText(
          key: Key('birthDate'),
          style: this.style,
          obscureText: false,
          controller: textInputControllerDate,
          hintText: "Birth Date",
          context: context,
          validator: Validator.validateDate,
        ),
        SizedBox(height: 25.0),
      ];
      focusNodeFirst.requestFocus();
      _phase++;
      return;
    }

    if (_phase == 0 && await validateFirstForm(key, context)) {
      this.interactiveForm = [
        FormTextField(
          key: Key('registerPassword'),
          style: this.style,
          obscureText: true,
          controller: textInputControllerPass,
          hintText: "Password",
          validator: Validator.validatePassword,
        ),
        SizedBox(height: 25.0),
        FormTextField(
            key: Key('RegisterRepeatPassword'),
            style: this.style,
            obscureText: true,
            hintText: "Repeat Password",
            validator: Validator.repeatValidatePassword,
            controller: textInputControllerRepeatPass)
      ];
      focusNodePas.requestFocus();

      _phase++;
      return;
    }
  }
}
