
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/permission_helper.dart';
import 'package:fridgify/utils/scanner_helper.dart';
import 'package:fridgify/view/popups/edit_value_popup.dart';
import 'package:fridgify/view/popups/no_item_found_popup.dart';
import 'package:fridgify/view/screens/add_item_screen.dart';
import 'package:fridgify/view/screens/fridge_users_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class FridgeDetailController {
  Function setState;
  Fridge fridge;
  Logger _logger = Logger('FridgeDetailController');

  bool isEditMode = false;
  List<Content> contents;

  BuildContext context;

  Set<Content> _selected = Set();

  FridgeDetailController(this.setState, this.fridge);

  FridgeRepository _fridgeRepository = FridgeRepository();

  UserService _userService = UserService();

  TextEditingController editNameController = TextEditingController();

  ScannerHelper _scannerHelper = ScannerHelper();

  bool isOwner(Fridge f) {
    var u = _userService.get();
    var users = f.members;

    for(User val in users.keys) {
      if(val.username == u.username)
        {
          if(users[val] == Permissions.owner)
            return true;
        }
    }
    return false;
  }

  Future<void> updateFridge(GlobalKey<FormState> key, BuildContext context, Function onChange, Fridge f) async {
    _logger.i("UPDATING FRIDGE");
    Loader.showSimpleLoadingDialog(context);
    if(key.currentState.validate()) {
      try {
        await _fridgeRepository.update(f, "name", editNameController.text);
        onChange(() {});
      }
      catch (exception) {
        _logger.e('SOMETHING WENT WRONG WHILE UPDATING FRIDGE', exception: exception);
      }
      Navigator.pop(context);
      Navigator.pop(context);
      Popups.infoPopup(context, "Fridge Renamed", "Fridge successfully renamed");
    }
  }

  Future<void> handleOptions(String string, BuildContext context) async {
    if(string == Constants.editFridge) {
      Popups.editPopup(context, this, setState, this.fridge);
      return;
    }

    if(string == Constants.addItem) {
      _logger.i("ADDING ITEM");


      var result = await _scannerHelper.scan();
      if(result == null) {
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddItemScreen(this.fridge.contentRepository, null, context, setState, _scannerHelper.getBarcode(result)),
            ));
        /*return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AddItemPopUp(this.fridge.contentRepository, null, context, setState, null);
          });*/
      }

      Item item = await _scannerHelper.fetchItem(result);

      if(item == null) {
        _logger.i("NO ITEM FOUND");
        await showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return NoItemFoundPopUp();
            }
        );
      }

      /*showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AddItemPopUp(this.fridge.contentRepository, item, context, setState, _scannerHelper.getBarcode(result));
          });*/
      Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddItemScreen(this.fridge.contentRepository, item, context, setState, _scannerHelper.getBarcode(result)),
          ));
    }
    if(string == Constants.showMembers) {
      await getUser(this.fridge, context);
    }
    setState(() {});
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





  showEditDialog(ContentRepository repository, content,
      BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return EditValuePopUp(repository, content, context, setState);
        });
  }

  cancelSelection() {
    setState(() {
      _selected = Set();
      isEditMode = false;
    });
  }

  selectGroup(List<Content> group) {
    isEditMode = true;
    _selected.addAll(group);
    setState(() {});
  }

  groupTap(group, ExpandableController expandableController) {
    if(isEditMode) {
      _selected.addAll(group);
    }
    else {
      expandableController.toggle();
    }

    setState(() {});
  }

  tileTapped(ContentRepository repo, Content content, BuildContext context) {
    isEditMode ?
    toggleSelection(content) :
    showEditDialog(repo, content, context);
  }

  deleteSelection(BuildContext context) {
    this.context = context;
    setState(() {
      Popups.confirmationPopup(
          context,
          "Delete ${_selected.length} items?", "Are you sure you would like to delete ${_selected.length} items from ${this.fridge.name}? It can't be undone.",
          _deleteItems
      );
    });
  }

  void toggleSelection(Content content) {
    this.isEditMode = true;
    setState(() {
      if (this._selected.contains(content)) {
        this._selected.remove(content);
      } else {
        this._selected.add(content);
      }
    });
  }

  Future<bool> _deleteItems() async {
    Loader.showSimpleLoadingDialog(this.context);
    try {
      await Future.wait(
        this._selected.map((e) => fridge.contentRepository.delete(e.contentId))
      );
      setState(() {});
      cancelSelection();
      Navigator.of(this.context).pop();
      return true;
    }
    catch (exception) {
      _logger.e("FAILED TO DELETE ITEMS", exception: exception);
      cancelSelection();
      Navigator.of(this.context).pop();
      return false;
    }
  }

  bool isSelected(Content content) {
    return _selected.contains(content);
  }

}
