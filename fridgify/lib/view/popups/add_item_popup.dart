import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/add_item_controller.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/widgets/form_elements.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class AddItemPopUp extends StatefulWidget {
  final ContentRepository repo;
  final BuildContext context;
  final Item item;
  final Function parentSetState;

  AddItemPopUp(this.repo, this.item,
      this.context, this.parentSetState);

  @override
  _AddItemPopUpState createState() =>
      _AddItemPopUpState(this.repo, this.item, this.context, this.parentSetState);
}

class _AddItemPopUpState extends State<AddItemPopUp> {
  final ContentRepository repo;
  final BuildContext context;
  final StoreRepository _storeRepository = StoreRepository();
  final Function parentSetState;
  AddItemController _controller;
  int startValue;
  Content content;
  Item item;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  _AddItemPopUpState(this.repo, this.item, this.context, this.parentSetState) {
    this._controller = AddItemController(contentRepository: this.repo);
  }

  Future<void> _addItem() async {
    Loader.showSimpleLoadingDialog(context);
    try {
      await _controller.addContent();
    }
    catch(exception)
    {
      Navigator.of(context).pop();
      Popups.errorPopup(context, "Failed to Add item $exception");
      return;
    }
    Navigator.of(context).pop();
    this.parentSetState(() {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(),
      title: Text('Add Item to ${this.repo.fridge.name}', style: style),
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            children: <Widget>[
              FormElements.textField(
                  style: style,
                  controller: _controller.itemNameController,
                  obscureText: false,
                  hintText: 'Item Name',
                  validator: Validator.validateUser),
              FormElements.datePickerText(
                style: style,
                context: context,
                controller: _controller.expirationDateController,
                hintText: "Expiration Date",
                obscureText: false,
                validator: Validator.validateDate,
                max: DateTime.now().add(Duration(days: 10000)),
              ),
              FormElements.numberField(
                  style: style,
                  controller: _controller.itemCountController,
                  obscureText: false,
                  hintText: 'Count',
                  validator: Validator.validateUser),
              FormElements.numberField(
                  style: style,
                  controller: _controller.itemAmountController,
                  obscureText: false,
                  hintText: 'Amount',
                  validator: Validator.validateUser),
              FormElements.textField(
                  style: style,
                  controller: _controller.itemUnitController,
                  obscureText: false,
                  hintText: 'Unit',
                  validator: Validator.validateUser),
              FormElements.autocompleteTextForm(
                  style: style,
                  controller: _controller.itemStoreController,
                  obscureText: false,
                  hintText: 'Store',
                  validator: Validator.validateUser,
                  suggestions: _storeRepository.getAllWithName().values.toList(),

              ),
            ],
          ),
        )
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
          child: Text('Add'),
          onPressed: () async => await _addItem(),
        ),
      ],
    );
  }
}