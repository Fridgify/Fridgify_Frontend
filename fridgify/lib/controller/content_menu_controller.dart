
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/hopper_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/scanner_helper.dart';
import 'package:fridgify/view/popups/invite_user_popup.dart';
import 'package:fridgify/view/popups/join_fridge_popup.dart';
import 'package:fridgify/view/screens/fridge_users_screen.dart';
import 'package:fridgify/view/screens/settings_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/menu_elements.dart';
import 'package:fridgify/view/widgets/popup.dart';


class ContentMenuController {
  AuthenticationService _authService = AuthenticationService();
  UserService _userService = UserService();
  FridgeRepository _fridgeRepository = FridgeRepository();
  ScannerHelper _scannerHelper = ScannerHelper();

  TextEditingController nameController = TextEditingController();
  TextEditingController editNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Function setState;
  BuildContext context;

  Logger _logger = Logger('ContentMenuController');
  HopperService _hopperService = HopperService();

  Future<void> qrCodeHandler() async {
    _scannerHelper.scanQr();
  }

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
    if(choice == Constants.hopper) {
      if(Repository.sharedPreferences.containsKey('hopper')) {
        Popups.infoPopup(context, 'Hopper', 'Already added notifications');
      }
      else {
        await _hopperService.requestToken();
      }
    }
    if(choice == Constants.settings) {
      Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          ));
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
      _logger.e("FAILED TO FETCH QR");
      Navigator.of(context).pop();
    }


  }

  Future<void> createFridge(GlobalKey<FormState> key, BuildContext context, Function onChange) async {
    _logger.i("CREATING FRIDGE");
    if(key.currentState.validate()) {
      try {
        await _fridgeRepository.add(Fridge.create(name: nameController.text));
        MenuElements.current = _fridgeRepository.getAll().length - 1;
        onChange();
      }
      catch (exception) {
        _logger.e('SOMETHING WENT WRONG WHILE CREATING FRIDGE', exception: exception);
      }
      Navigator.pop(context);
    }
  }
  Future<void> updateFridge(GlobalKey<FormState> key, BuildContext context, Function onChange, Fridge f) async {
    _logger.i("UPDATING FRIDGE");
    Loader.showSimpleLoadingDialog(context);
    if(key.currentState.validate()) {
      try {
        await _fridgeRepository.update(f, "name", editNameController.text);
        onChange();
      }
      catch (exception) {
        _logger.e('SOMETHING WENT WRONG WHILE CREATING FRIDGE', exception: exception);
      }
      Navigator.pop(context);
      Navigator.pop(context);
      Popups.infoPopup(context, "Fridge Renamed", "Fridge successfully renamed");
      onChange();
    }
  }

  Future<void> showPopUp(Uri url) async {

    if(Repository.sharedPreferences.containsKey(url.toString())) {
      return;
    }

    await Repository.sharedPreferences.setBool(url.toString(), true);

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


    _logger.i("FOUND DEEP LINK $deepLink");

    if (deepLink != null) {
      if(deepLink.queryParameters.containsKey('id')) {
        _hopperService.registerToken(deepLink.queryParameters['id'], context);
        return;
      }
      else {
        showPopUp(deepLink);
      }
      //Navigator.pushNamed(context, deepLink.path);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;


          _logger.i("FOUND DEEP LINK 2 $deepLink");
          if (deepLink != null) {
            if(deepLink.queryParameters.containsKey('id')) {
              _hopperService.registerToken(deepLink.queryParameters['id'], context);
              return;
            }
            else {
              _logger.i("FOUND QUERY PARAMETERS 2 ${deepLink.queryParameters}");
              showPopUp(deepLink);
            }//Navigator.pushNamed(context, deepLink.path);
          }
        },
        onError: (OnLinkErrorException e) async {
          _logger.e('onLinkError', exception: e, popup: false);
        }
    );
  }
}