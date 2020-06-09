import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/add_item_controller.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/widgets/form_elements.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class AddItemPopUp extends StatefulWidget {
  final ContentRepository repo;
  final BuildContext context;
  final Item item;
  final Function parentSetState;
  final String barcode;

  AddItemPopUp(this.repo, this.item,
      this.context, this.parentSetState, this.barcode);

  @override
  _AddItemPopUpState createState() =>
      _AddItemPopUpState(this.repo, this.item, this.context, this.parentSetState, this.barcode);
}

class _AddItemPopUpState extends State<AddItemPopUp> {
  final ContentRepository repo;
  final BuildContext context;
  final StoreRepository _storeRepository = StoreRepository();
  final Function parentSetState;

  Logger _logger = Logger('AddItemPopUp');

  AddItemController _controller;
  int startValue;
  Content content;
  Item item;
  String barcode;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  _AddItemPopUpState(this.repo, this.item, this.context, this.parentSetState, this.barcode) {
    this._controller = AddItemController(contentRepository: this.repo, item: item);
  }

  Future<void> _addItem() async {
    Loader.showSimpleLoadingDialog(context);
    try {
      await _controller.addContent(barcode);
    }
     catch(exception)
    {
      Navigator.of(context).pop();

      _logger.e("FAILED TO ADD ITEM", exception: exception);
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
              FormTextField(
                  style: style,
                  controller: _controller.itemNameController,
                  obscureText: false,
                  hintText: 'Item Name',
                  validator: Validator.validateUser),
              DatePickerText(
                style: style,
                context: context,
                controller: _controller.expirationDateController,
                hintText: "Expiration Date",
                obscureText: false,
                validator: Validator.validateDate,
                max: DateTime.now().add(Duration(days: 10000)),
              ),
              NumberField(
                  style: style,
                  controller: _controller.itemCountController,
                  obscureText: false,
                  hintText: 'Count',
                  validator: Validator.validateUser,
              maxNumber: 100,),
              NumberField(
                  style: style,
                  controller: _controller.itemAmountController,
                  obscureText: false,
                  hintText: 'Amount',
                  validator: Validator.validateUser),
              FormTextField(
                  style: style,
                  controller: _controller.itemUnitController,
                  obscureText: false,
                  hintText: 'Unit',
                  validator: Validator.validateUser),
              AutocompleteTextForm(
                  style: style,
                  controller: _controller.itemStoreController,
                  obscureText: false,
                  hintText: 'Store',
                  validator: Validator.validateUser,
                  suggestions: _storeRepository.getAllWithName().values.toSet().toList(),

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
