import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class ChangeEmailPopUp extends StatefulWidget {
  final BuildContext context;
  final Function parentSetState;

  ChangeEmailPopUp(this.context, this.parentSetState);

  @override
  _ChangeEmailPopUpState createState() =>
      _ChangeEmailPopUpState(this.context, this.parentSetState);
}

class _ChangeEmailPopUpState extends State<ChangeEmailPopUp> {
  final UserService _userService = UserService();
  final BuildContext context;
  final Function parentSetState;
  final Logger _logger = Logger('ChangeEmailPopUp');
  final TextEditingController _controller = TextEditingController();
  String name;
  int startValue;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  _ChangeEmailPopUpState(this.context, this.parentSetState) {
    _controller.text = _userService.user.email;
  }

  Future<void> _updateEmail() async {
    Loader.showSimpleLoadingDialog(context);
    await _userService.update(_userService.user, 'email', _controller.text);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Popups.infoPopup(context, "Changed Password", "Changed password successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Change Email', style: style),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,

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
          onPressed: () async => await _updateEmail(),
        ),
      ],
    );
  }
}
