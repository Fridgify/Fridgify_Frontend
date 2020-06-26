import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fridgify/controller/add_item_controller.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/screens/list_suggestions_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:fridgify/view/widgets/popup.dart';

class AddItemScreen extends StatefulWidget {
  final ContentRepository repo;
  final BuildContext context;
  final Item item;
  final Function parentSetState;
  final String barcode;

  AddItemScreen(
      this.repo, this.item, this.context, this.parentSetState, this.barcode);

  @override
  _AddItemScreenState createState() => _AddItemScreenState(
      this.repo, this.item, this.context, this.parentSetState, this.barcode);
}

class _AddItemScreenState extends State<AddItemScreen> {
  final ContentRepository repo;
  final BuildContext context;
  final Item item;
  final Function parentSetState;
  final String barcode;
  final StoreRepository _storeRepository = StoreRepository();
  final ItemRepository _itemRepository = ItemRepository();

  Logger _logger = Logger('AddItemScreen');

  AddItemController _controller;
  int startValue;
  Content content;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  _AddItemScreenState(
      this.repo, this.item, this.context, this.parentSetState, this.barcode) {
    this._controller =
        AddItemController(item: this.item, contentRepository: this.repo);
  }

  void _checkValue(int maxNumber) {
    if (int.parse(_controller.itemCountController.text) > maxNumber) {
      _controller.itemCountController.text = maxNumber.toString();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.itemCountController.addListener(() => _checkValue(100));
  }

  bool isSwitched = true;
  String old = "";


  @override
  Widget build(BuildContext context) {


    final widgets = <Widget>[
      ListTile(
          title: Text("Item Name"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                _controller.itemNameController.text,
                style: style,
              ),
              Icon(
                Icons.arrow_forward_ios,
              )
            ],
          ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ListSuggestionsScreen(
                  "Select an item",
                  "Item",
                  _itemRepository.getAll().values.map((e) => e.name).toSet().toList(),
                  _controller.itemNameController),
            ));
            setState(() {});
          }),
      ListTile(
        title: Text("Expires"),
        trailing: Switch(
          value: isSwitched,
          onChanged: (value) {
            setState(() {
              isSwitched = value;
              DateTime date = DateTime.now();
              if(!isSwitched) {
                old = _controller.expirationDateController.text ?? "${date.year}-${date.month < 10 ? "0${date.month}" : date.month}-${date.day < 10 ? "0${date.day}" : date.day}";
                _controller.expirationDateController.text = "9999-12-12";
              }
              else {
                _controller.expirationDateController.text = old;
              }
            });
          },
          activeTrackColor: Colors.purpleAccent,
          activeColor: Colors.purple,
        ),
      ),
      ListTile(
        enabled: (isSwitched),
        title: Text("Expiration Date"),
        trailing: Text(_controller.expirationDateController.text),
        onTap: () {
          if(!isSwitched) return;
          DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: DateTime(1900, 1, 1),
              maxTime: DateTime.now().add(Duration(days: 10000)),
              theme: DatePickerTheme(
                  headerColor: Colors.white,
                  backgroundColor: Colors.white,
                  itemStyle: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  doneStyle: TextStyle(color: Colors.purple, fontSize: 16)),
              onChanged: (date) {}, onConfirm: (date) {
            _controller.expirationDateController.text =
                "${date.year}-${date.month < 10 ? "0${date.month}" : date.month}-${date.day < 10 ? "0${date.day}" : date.day}";
            setState(() {});
          }, currentTime: DateTime.now(), locale: LocaleType.en);
        },
      ),
      ListTile(
          title: Text("Count"),
          trailing: new Container(
            width: 50.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Expanded(
                  flex: 3,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    controller: _controller.itemCountController,
                    //_controller.textInputControllerUser,
                    validator: (value) => Validator.validateUser(value),
                    decoration: InputDecoration(
                      hintText: "Count", //"Username",
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
      ListTile(
        title: Text("Amount"),
        trailing: new Container(
          width: 50.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                flex: 3,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                  controller: _controller.itemAmountController,
                  //_controller.textInputControllerUser,
                  validator: (value) => Validator.validateUser(value),
                  decoration: InputDecoration(
                    hintText: "Amount", //"Username",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ListTile(
        title: Text("Unit"),
        trailing: new Container(
          width: 50.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                flex: 3,
                child: TextFormField(
                    style: style,
                    controller: _controller.itemUnitController,
                    //_controller.textInputControllerUser,
                    validator: (value) => Validator.validateUser(value),
                    decoration: InputDecoration(
                      hintText: "Unit", //"Username",)),
                    )),
              ),
            ],
          ),
        ),
      ),
      ListTile(
          title: Text("Store"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                _controller.itemStoreController.text,
                style: style,
              ),
              Icon(
                Icons.arrow_forward_ios,
              )
            ],
          ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ListSuggestionsScreen(
                  "Select the Store",
                  "Store",
                  _storeRepository.getAll().values.map((e) => e.name).toList(),
                  _controller.itemStoreController),
            ));
            setState(() {});
          }),
      ListTile(
        enabled: false,
        title: Text("Barcode"),
        trailing: Text(barcode ?? ""),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return widgets[index];
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: widgets.length),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(
          Icons.save,
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    if(!_controller.validateController()) {
      Popups.infoPopup(context, "Failed to add item", "Please fill out all fields!");
      return;
    }
    Loader.showSimpleLoadingDialog(context);
    try {
      await _controller.addContent(barcode);
    } catch (exception) {
      Navigator.of(context).pop();

      _logger.e("FAILED TO ADD ITEM", exception: exception);
      return;
    }
    Navigator.of(context).pop();
    this.parentSetState(() {});
    Navigator.of(context).pop();
  }
}
