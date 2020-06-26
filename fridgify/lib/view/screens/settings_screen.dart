import 'package:flutter/material.dart';
import 'package:fridgify/controller/settings_controller.dart';
import 'package:fridgify/utils/web_helper.dart';
import 'package:fridgify/view/popups/change_email_popup.dart';
import 'package:fridgify/view/popups/change_password_popup.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsController _controller = SettingsController();
  WebHelper _webHelper = WebHelper();

  @override
  Widget build(BuildContext context) {
    final widgets = [
      ListTile(
          title: Text('Change Email'),
          onTap: () => showDialog(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return ChangeEmailPopUp(
                  context,
                  setState,
                );
              })),
      ListTile(
          title: Text('Change Password'),
          onTap: () => showDialog(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return ChangePasswordPopUp(context, setState);
              })),
      ListTile(
        onTap: () async => await _controller.addHopper(context),
        title: Text('Add Hopper Notifications'),
      ),
      ListTile(
        title: Text('Developers Blog'),
        onTap: () => _webHelper.launchUrl("https://blog.fridgify.com/"),
      ),
      ListTile(
        title: Text('Dataprivacy'),
        onTap: () => _webHelper.launchUrl("https://blog.fridgify.com/privacy-policy/"),
      ),
      ListTile(
        onTap: () => _controller.deleteUser(context),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: widgets.length,
        itemBuilder: (context, index) => widgets[index],
      ),
    );
  }
}
