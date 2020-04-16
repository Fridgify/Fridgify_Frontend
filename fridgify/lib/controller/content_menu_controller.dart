
import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/menu_elements.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:logger/logger.dart';

class ContentMenuController {
  AuthenticationService _authService = AuthenticationService();
  FridgeRepository _fridgeRepository = FridgeRepository();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Logger _logger = Logger();

  Future<void> choiceAction(String choice, BuildContext context, Function onChange) async {
    if(choice == Constants.logout) {
      if(await _authService.logout(context)){
        await Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false);
      }
    }
    if(choice == Constants.addFridge) {
      print('Pop');
      Popups.addFridge(context, this, onChange);
    }
    print("Pressed");
  }

  Future<void> leaveFridge(Fridge f, BuildContext context, Function onChanged) async {
    Loader.showSimpleLoadingDialog(context);
    await _fridgeRepository.delete(f.fridgeId);
    Navigator.pop(context);
    MenuElements.current = 0;
    onChanged();
  }

  Future<void> createFridge(GlobalKey<FormState> key, BuildContext context, Function onChange) async {
    _logger.i("ContentMenuController => CREATING FRIDGE");
    if(key.currentState.validate()) {
      try {
        await _fridgeRepository.add(Fridge.create(name: nameController.text,
            description: descriptionController.text ?? ""));
        MenuElements.current = _fridgeRepository.getAll().length - 1;
        onChange();
      }
      catch (exception) {
        Popups.errorPopup(context, exception.toString());
      }
      Navigator.pop(context);
    }
  }
}