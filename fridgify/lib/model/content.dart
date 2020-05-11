import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/utils/item_state_helper.dart';
import 'package:logger/logger.dart';

import 'fridge.dart';
import 'item.dart';

class Content {
  String contentId;
  String expirationDate;
  int amount;
  int count;
  int maxAmount;
  String unit;
  Fridge fridge;
  Item item;
  ItemState state;

  Logger _logger = Logger();

  Content({
    @required this.contentId,
    @required this.expirationDate,
    @required this.amount,
    @required this.maxAmount,
    @required this.unit,
    @required this.item,
    @required this.fridge,
  }) {
    setItemState();
  }

  Content.create({
    this.contentId,
    @required this.count,
    @required this.expirationDate,
    @required this.amount,
    @required this.unit,
    @required this.item,
  }) {
    ItemRepository _itemRepository = ItemRepository();
    _itemRepository.add(item);
    this.maxAmount = this.amount;
    setItemState();
  }

  void setItemState() {
    print(this.expirationDate);
    var date = DateTime.parse(this.expirationDate);
    print("STATE => ${DateTime.now().subtract(Duration(days: 5))}");
    print("STATE => $date");
    _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} AND DATE: $date / ${this.expirationDate}');

    if(date.isAfter(DateTime.now().add(Duration(days: 5)))) {
      _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} FRESH');
      this.state = ItemState.fresh;
    }
    else if(date.isBefore(DateTime.now().add(Duration(days: 5))) && date.isAfter(DateTime.now())) {
      _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} DUE SOON');
      this.state = ItemState.dueSoon;
    }
    else {
      _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} OVER DUE');
      this.state = ItemState.overDue;
    }
  }

  @override
  String toString() {
    return "expirationDate: ${this.expirationDate}, amount: ${this.amount}, "
        "unit: ${this.unit}"
        "fridgeId: ${this.fridge}";
  }
}
