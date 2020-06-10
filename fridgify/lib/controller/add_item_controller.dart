
import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_add_content_exception.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/logger.dart';

class AddItemController {
  StoreRepository _storeRepository = StoreRepository();
  ItemRepository _itemRepository = ItemRepository();
  ContentRepository contentRepository;
  Logger _logger = Logger('AddItemController');

  TextEditingController itemNameController = TextEditingController();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  TextEditingController itemAmountController = TextEditingController();
  TextEditingController itemUnitController = TextEditingController();
  TextEditingController itemStoreController = TextEditingController();
  String barcode = "";
  Item item;

  AddItemController({this.contentRepository, this.item}) {
    itemNameController.text = this.item != null ? this.item.name : "";
    expirationDateController.text = "";
    itemCountController.text = "";
    itemAmountController.text = "";
    itemUnitController.text = "";
    itemStoreController.text = this.item != null ? this.item.store : "";
  }


  Future<Content> addContent(String barcode) async {
    _logger.i("ADDING ITEM ${itemNameController.text} ${expirationDateController.text} ${itemCountController.text}"
        "${itemAmountController.text} ${itemUnitController.text} ${itemStoreController.text} and Barcode $barcode");


    Content c = Content.create(
        amount: int.parse(itemAmountController.text),
        expirationDate: "${expirationDateController.text}",
        unit: itemUnitController.text,
        count: int.parse(itemCountController.text),
        item: Item.create(name: itemNameController.text,
            store: await _storeRepository.getByName(itemStoreController.text), barcode: barcode ?? "")
    );

    try {
      _logger.i("ADDING CONTENT $c");
      await this.contentRepository.add(c);
      await this._itemRepository.fetchAll();
      this.contentRepository.group();
      return c;
    }
    catch(exception) {
      _logger.e("FAILED TO ADD ITEM", exception: exception);
      throw FailedToAddContentException(exe: exception);
    }
  }

}