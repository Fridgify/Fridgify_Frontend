
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:fridgify/view/popups/invite_user_popup.dart';
import 'package:fridgify/view/popups/join_fridge_popup.dart';
import 'package:fridgify/view/screens/fridge_users_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/menu_elements.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:logger/logger.dart';

class ContentMenuController {
  AuthenticationService _authService = AuthenticationService();
  UserService _userService = UserService();
  FridgeRepository _fridgeRepository = FridgeRepository();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Function setState;
  BuildContext context;

  Logger _logger = Logger();

  Future<void> choiceAction(String choice, BuildContext context, Function onChange) async {
    if(choice == Constants.logout) {
      if(await _authService.logout()){
        await Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false);
      }
    }
    if(choice == Constants.addFridge) {
      Popups.addFridge(context, this, onChange);
    }
  }

  Future<void> leaveFridge(Fridge f, BuildContext context, Function onChanged) async {
    Loader.showSimpleLoadingDialog(context);
    await _fridgeRepository.delete(f.fridgeId);
    Navigator.pop(context);
    MenuElements.current = 0;
    onChanged();
  }

  Future<void> getUser(Fridge f, BuildContext context) async {
    Loader.showSimpleLoadingDialog(context);
    var users = f.members;
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UsersPage(users, f),
        ));
  }

  Future<void> generateQr(Fridge f, BuildContext context) async {
    String qr;

    Loader.showSimpleLoadingDialog(context);
    try {
      qr = await _userService.fetchDeepLink(f);
      Navigator.of(context).pop();
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return InviteUserPopUp(qr);
          }
      );
    }
    catch(exception) {
      _logger.e("ContentMenuController => FAILED TO FETCH QR");
      Navigator.of(context).pop();
    }

    print(qr);

  }

  Future<void> createFridge(GlobalKey<FormState> key, BuildContext context, Function onChange) async {
    _logger.i("ContentMenuController => CREATING FRIDGE");
    if(key.currentState.validate()) {
      try {
        await _fridgeRepository.add(Fridge.create(name: nameController.text));
        MenuElements.current = _fridgeRepository.getAll().length - 1;
        onChange();
      }
      catch (exception) {
        Popups.errorPopup(context, exception.toString());
      }
      Navigator.pop(context);
    }
  }

  Future<void> showPopUp(Uri url) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return JoinFridgePopUp(url, this.setState);
        }
    );
  }

  Future<void> retrieveDynamicLink() async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    print("deep $deepLink");

    if (deepLink != null) {
      showPopUp(deepLink);
      //Navigator.pushNamed(context, deepLink.path);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          print("deep $deepLink");
          if (deepLink != null) {
            showPopUp(deepLink);
            //Navigator.pushNamed(context, deepLink.path);
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );
  }
}