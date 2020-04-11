import 'package:flutter/cupertino.dart';

import 'fridge.dart';
import 'item.dart';

class Content {
  String expirationDate;
  int amount;
  String unit;
  Fridge fridge;
  Item item;

  Content({
    @required this.expirationDate,
    @required this.amount,
    @required this.unit,
    @required this.item,
    @required this.fridge,
  });

  Content.create({
    @required this.expirationDate,
    @required this.amount,
    @required this.unit,
    @required this.item,
  });

  @override
  String toString() {
    return "expirationDate: ${this.expirationDate}, amount: ${this.amount}, "
        "unit: ${this.unit}"
        "fridgeId: ${this.fridge}";
  }
}
