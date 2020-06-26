import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class ChangePasswordPopUp extends StatefulWidget {
  final BuildContext context;
  final Function parentSetState;

  ChangePasswordPopUp(this.context, this.parentSetState);

  @override
  _ChangePasswordPopUpState createState() =>
      _ChangePasswordPopUpState(this.context, this.parentSetState);
}

class _ChangePasswordPopUpState extends State<ChangePasswordPopUp> {
  final UserService _userService = UserService();
  final BuildContext context;
  final Function parentSetState;
  final Logger _logger = Logger('ChangePasswordPopUp');
  TextEditingController textInputControllerPass = TextEditingController();
  TextEditingController textInputControllerRepeatPass = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  String name;
  int startValue;
  GlobalKey<FormState> key = GlobalKey();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  _ChangePasswordPopUpState(this.context, this.parentSetState) {
    _controller.text = _userService.user.email;
  }

  Future<void> _updatePassword() async {
    Loader.showSimpleLoadingDialog(context);
    if(!await validateForm())
      return;
    await _userService.update(_userService.user, 'password', textInputControllerPass.text);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Popups.infoPopup(context, "Changed Password", "Changed password successfully!");
  }

  Future<bool> validateForm() async {
    Validator.doNotMatch =
        textInputControllerPass.text != textInputControllerRepeatPass.text;
    _logger.i(
        "VALIDATING INPUT DO NOT MATCH: ${Validator.doNotMatch}");

    return key.currentState.validate();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Change Password', style: style),
      content: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(

            children: [
              TextFormField(
                key: Key('registerPassword'),
                obscureText: true,
                controller: textInputControllerPass,
                decoration: InputDecoration(
                  hintText: "Password",
                ),
                validator: (value) => Validator.validatePassword(value),
              ),
              TextFormField(
                key: Key('repeatRegisterPassword'),
                obscureText: true,
                controller: textInputControllerRepeatPass,
                decoration: InputDecoration(
                  hintText: "Repeat Password",
                ),
                validator: (value) => Validator.repeatValidatePassword(value),
              ),
            ],
          ),
        ),//
      ),
      actions: <Widget>[
        FlatButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.center,
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.purple),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          }, //() =>
          //Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => RegisterPage())),
        ),
        RaisedButton(
          color: Colors.purple,
          child: Text('Save'),
          onPressed: () async => await _updatePassword(),
        ),
      ],
    );
  }
}
