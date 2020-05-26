import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class InviteUserPopUp extends StatefulWidget {
  final String url;

  InviteUserPopUp(this.url);

  @override
  _InviteUserPopUpState createState() =>
      _InviteUserPopUpState(this.url);
}

class _InviteUserPopUpState extends State<InviteUserPopUp> {

  final String url;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  _InviteUserPopUpState(this.url);


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Invite user to fridge', style: style),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Container(
                height: 300,
                width: 300,
        child:
            QrImage(
              data: this.url,
              version: QrVersions.auto,
              size: 300,
            )
            )
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        RaisedButton(
          color: Colors.purple,
          child: Text('Share invitation link'),
          onPressed: () async {
            await share(url, context);
          },
        ),
      ],
    );

  }

  Future<void> share(String url, BuildContext context) async {
    Loader.showSimpleLoadingDialog(context);
    final RenderBox box = context.findRenderObject();
    await Share.share(url,
        subject: url,
        sharePositionOrigin:
        box.localToGlobal(Offset.zero) &
        box.size);
    Navigator.of(context).pop();
  }
}
