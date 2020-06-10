import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/view/widgets/item_circular_slider.dart';
import 'package:fridgify/view/widgets/popup.dart';

class EditValuePopUp extends StatefulWidget {
  final ContentRepository repo;
  final Content content;
  final BuildContext context;
  final Function parentSetState;

  EditValuePopUp(this.repo, this.content, this.context, this.parentSetState);

  @override
  _EditValuePopUpState createState() =>
      _EditValuePopUpState(this.repo, this.content, this.context, this.parentSetState);
}

class _EditValuePopUpState extends State<EditValuePopUp> {
  final ContentRepository repo;
  final Content content;
  final BuildContext context;
  final Function parentSetState;
  final Logger _logger = Logger('EditValuePopUp');
  int startValue;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  _EditValuePopUpState(this.repo, this.content, this.context, this.parentSetState) {
    startValue = this.content.amount;
  }

  Future<void> _updateItem() async {
    if(startValue <= content.amount)
      {
        Popups.errorPopup(context, "Failed to update item ${content.amount} is not smaller than $startValue");
        return;
      }
    try {
      await this.repo.withdraw(content, startValue - content.amount);
    }
    catch(exception) {
      _logger.e("FAILED TO UPDATE ITEM", exception: exception, popup: false);
    }
    this.parentSetState(() {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Edit Value of ${this.content.item.name}', style: style),
      content: SingleChildScrollView(
        child: ItemCircularSlider(content),
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
              "Cancel", //"DON'T HAVE AN ACCOUNT?",
              style: TextStyle(color: Colors.purple),
            ),
          ),
          onPressed: () {
            content.amount = this.startValue;
            Navigator.of(context).pop();
          }, //() =>
          //Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => RegisterPage())),
        ),
        RaisedButton(
          color: Colors.purple,
          child: Text('Save'),
          onPressed: () async => await _updateItem(),
        ),
      ],
    );
  }
}
