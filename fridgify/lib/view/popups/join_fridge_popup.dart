import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class JoinFridgePopUp extends StatefulWidget {
  final Uri url;
  final Function parentSetState;

  JoinFridgePopUp(this.url, this.parentSetState);

  @override
  _JoinFridgePopUpState createState() =>
      _JoinFridgePopUpState(this.url, this.parentSetState);
}

class _JoinFridgePopUpState extends State<JoinFridgePopUp> {
  Uri url;
  final Function parentSetState;

  FridgeRepository _fridgeRepository = FridgeRepository();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final Logger _logger = Logger('JoinFridgePopUp');

  _JoinFridgePopUpState(this.url, this.parentSetState);

  Future<void> _joinFridgeWithQr() async {
    Loader.showSimpleLoadingDialog(context);
    try {
      await _fridgeRepository.joinByUrl(this.url);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      this.parentSetState(() {

      });
    }
    catch(exception) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Popups.errorPopup(context, "Failed to join fridge, please request a new url");
      _logger.e('FAILED TO JOIN FRIDGE $exception');
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Join fridge?', style: style),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("Would you like to join this fridge?"),
          ],
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          color: Colors.purple,
          child: Text('Yes'),
          onPressed: () => _joinFridgeWithQr(),
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () {
            Navigator.of(context).pop();

          },
        )
      ],
    );
  }
}
